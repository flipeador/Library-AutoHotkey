/*   :::: EXAMPLE ::::
Gui := GuiCreate()
    Gui.SetFont("s10", "Courier New")
TC := new Tab(Gui, "x5 y5 w500 h400", "Pestaña 1", "Pestaña 2", "Pestaña 3")

;TC.SetItemSize(50,50)
DA := TC.GetDisplayArea()

ImageList := IL_Create()
IL_Add(ImageList, A_ComSpec)
IL_Add(ImageList, A_WinDir . "\regedit.exe")
IL_Add(ImageList, A_WinDir . "\explorer.exe")
TC.SetImageList(ImageList)

TC.SetItemImage(0, 0)    ; (índice basado en cero de la pestaña, índice basado en cero de la imagen en la lista de imagenes)
TC.SetItemImage(1, 1)    ;  //
TC.SetItemImage(2, 2)    ;  //

TC.UseTab(0)    ; Pestaña 1
Gui.AddEdit(Format("x{} y{} w{} h{} cFFFFFF Background0",DA.GX,DA.GY,DA.W,DA.H), "`r`n>Tab Control Class<`r`n")

TC.UseTab(1)    ; Pestaña 2
Gui.AddListView(Format("x{} y{} w{} h{}",DA.GX,DA.GY,DA.W,DA.H), "Columna 1|Columna 2|Columna 3")

TC.UseTab(2)    ; Pestaña 3
Gui.AddActiveX(Format("x{} y{} w{} h{}",DA.GX,DA.GY,DA.W,DA.H), "shell.explorer").Value.Navigate("google.com")

TC.UseTab()     ; Future controls are not part of any tab

Gui.Show("w510 h410")
    Gui.OnEvent("Close", "ExitApp")
Return

F1:: ToolTip(TC.HitTest().Item . "|" . TC.HitTest().Pos)
*/









Class Tab
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES
    ; ===================================================================================================================
    static CtrlList := {}    ; almacena una lista con todos los controles: {ControlID:ComboBoxExObj}.


    /*
        Añade un control Tab en la ventana GUI especificada.
        Parámetros:
            Gui:
                El objeto de ventana GUI. También puede especificar un objeto control existente (o su identificador).
            Options:
                Las opciones para el nuevo control. Especificar 'chooseN' para auto-seleccionar una pestaña luego de crear el control (N es la posición basada en cero de la pestaña).
            Items:
                Una lista de elementos a añadir en el control.
    */
    __New(Gui, Options := "", Items*)
    {
        if (Type(Gui) != "Gui")
        {
            Gui := IsObject(Gui) ? Gui.Hwnd : Gui
            local k := "", v := ""
            for k, v in Tab.CtrlList
                if (k == Gui)
                    return v
            return 0
        }

        ; Tab Control Reference
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/bumper-tab-tab-control-reference
        this.ctrl := Gui.AddTab3("-0x200 " . Options, A_Space)
        this.hWnd := this.ctrl.Hwnd
        this.gui  := Gui
        this.Type := "Tab"

        this.Buffer := "", ObjSetCapacity(this, "Buffer", 40)
        this.ptr := ObjGetAddress(this, "Buffer")
        
        this.Delete(0)
        If (ObjLength(Items))   ; añade los elementos especificados
        {
            local k := "", v := ""
            For k, v in Items
                this.Add(-1, String(v))
            If (RegExMatch(Options, "i)\bchoose(\d+)\b", k))    ; posición basada en cero del elemento a seleccionar
                this.Selected := k[1]
        }
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Elimina el control.
    */
    Destroy()
    {
        ObjDelete(this.CtrlList, this.hWnd)
        DllCall("User32.dll\DestroyWindow", "Ptr", this.hWnd)
    }

    /*
        Añade un elemento en la posición especificada.
        Parámetros:
            Item:
                El índice basado en cero del nuevo elemento (pestaña). Para insertar un elemento al final de la lista, establezca el parámetro en -1.
            Text:
                Si es una cadena especifica el texto a mostrar para este elemento.
                Si es un valor de tipo entero especifica la dirección de memoria a una cadena a mostrar para este elemento. Puede ser cero para dejar sin texto asignado.
            Image:
                Índice en la lista de imágenes del control. El valor por defecto es -1, que indica sin imagen.
            Data:
                Datos definidos por la aplicación asociados con el elemento. Para asignar un objeto o una cadena pase la dirección de memoria.
        Return:
            Devuelve el índice basado en cero del nuevo elemento si tuvo éxito, o -1 en caso contrario.
    */
    Add(Item := -1, Text := 0, Image := -1, Data := 0)
    {
        ; TCM_INSERTITEM message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-insertitem
        NumPut(1|2|8|0x10, this.ptr, "Int64")    ; TCIF_TEXT|TCIF_IMAGE|TCIF_PARAM|TCIF_STATE
      , NumPut(Type(Text) = "integer" ? Text : &Text, this.ptr+8+A_PtrSize, "UPtr")
      , NumPut(Data, NumPut(Image, this.ptr+12+2*A_PtrSize, "Int"), "Ptr")
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x133E, "Ptr", Item==-1?this.GetCount():Item, "UPtr", this.ptr, "Ptr")
    }

    /*
        Recupera el texto del elemento especificado.
        Parámetros:
            Length:
                La longitud máxima del texto a recuperar, en caracteres. Por defecto solo recupera los primeros 1000 caracteres.
        Return:
            Si tuvo éxito devuelve el texto del elemento y ErrorLevel se establece en cero.
            Si hubo un error devuelve una cadena vacía y ErrorLevel se establece en un valor distinto de cero.
            Si el elemento no tiene texto asignado, devuelve una cadena vacía y ErrorLevel se establece en cero.
    */
    GetText(Item, Length := 1000)
    {
        if (!(Length is "integer") || Length < 0)
            throw Exception("Class Tab::GetText invalid parameter #2", -1)
        ; TCM_GETITEM message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-getitem
        local buffer := ""
        VarSetCapacity(buffer, Length*2+2, 0), NumPut(1, this.ptr, "UInt")
      , NumPut(Length+1, NumPut(&buffer, this.ptr+8+A_PtrSize, "UPtr"), "Int")
      , ErrorLevel := !DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x133C, "Ptr", Item, "UPtr", this.ptr)
        return ErrorLevel ? "" : StrGet(&buffer, "UTF-16")
    }

    /*
        Establece el texto del elemento especificado.
        Parámetros:
            Text:
                Si es una cadena especifica el texto para el elemento.
                Si es un entero especifica la dirección de memoria de una cadena. Si especifica cero el elemento no tendrá ningún texto asignado.
        Return:
            Si tuvo éxito devuelve un valor distinto de cero, o cero en caso contrario.
    */
    SetText(Item, Text)
    {
        ; TCM_SETITEM message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-setitem
        NumPut(Type(Text) = "integer" ? Text : &Text, NumPut(1, this.ptr, "Int64")+A_PtrSize, "UPtr")
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x133D, "Ptr", Item, "UPtr", this.ptr)
    }

    /*
        Recupera el índice basado en cero de la imagen en la lista de imagenes del elemento especificado.
        Return:
            Si tuvo éxito devuelve el índice en la lista de imagenes, o una cadena vacía si hubo un error.
    */
    GetItemImage(Item)
    {
        ; TCM_GETITEM message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-getitem
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x133C, "Ptr", Item, "UPtr", NumPut(2, this.ptr, "UInt")-4) ? NumGet(this.ptr+12+2*A_PtrSize, "Int") : ""
    }

    /*
        Establece el índica asado en cero de la imagen en la lista de imagenes para el elemento especificado.
        Return:
            Si tuvo éxito devuelve un valor distinto de cero, o cero en caso contrario.
    */
    SetItemImage(Item, Image)
    {
        ; TCM_SETITEM message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-setitem
        NumPut(Image, NumPut(2, this.ptr, "UInt")+8+2*A_PtrSize, "Int")
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x133D, "Ptr", Item, "UPtr", this.ptr)
    }

    /*
        Recupera un valor de tipo entero con signo asociado al elemento especificado.
        Return:
            Si tuvo éxito devuelve el valor, o de lo contrario una cadena vacía.
    */
    GetItemData(Item)
    {
        ; TCM_GETITEM message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-getitem
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x133C, "Ptr", Item, "UPtr", NumPut(8, this.ptr, "UInt")-4) ? NumGet(this.ptr+16+2*A_PtrSize, "Ptr") : ""
    }

    /*
        Establece el valor de tipo entero con signo asociado al elemento.
        Return:
            Si tuvo éxito devuelve un valor distinto de cero, o cero en caso contrario.
    */
    SetItemData(Item, Data)
    {
        ; TCM_SETITEM message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-setitem
        NumPut(Data, NumPut(8, this.ptr, "UInt")+12+2*A_PtrSize, "Ptr")
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x133D, "Ptr", Item, "UPtr", this.ptr)
    }

    /*
        Recupera el estado del elemento especificado.
        Return:
            Si tuvo éxito devuelve un valor entero con los estados, o una cadena vacía en caso contrario.
    */
    GetItemState(Item)
    {
        ; TCM_GETITEM message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-getitem
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x133C, "Ptr", Item, "UPtr", NumPut(0x10, this.ptr, "UInt")-4) ? NumGet(this.ptr+4, "UInt") : ""
    }

    /*
        Cambia el estado del elemento especificado.
        Parámetros:
            State:
                Contiene el valor de estado que se establecerá para el elemento. Puede ser uno o más de los siguientes valores.
                1 (TCIS_BUTTONPRESSED) = El elemento está seleccionado. Este estado solo tiene sentido si se ha establecido el estilo TCS_BUTTONS.
                2 (TCIS_HIGHLIGHTED)   = El elemento se resalta, y la pestaña y el texto se dibujan usando el color de resaltado actual.
                Referencia - https://docs.microsoft.com/es-es/windows/desktop/Controls/tab-control-item-states
            StateMask:
                Especifica qué bits del parámetro «State» contienen información válida. Por defecto sobre-escribe todos los estados.
        Return:
            Si tuvo éxito devuelve un valor distinto de cero, o cero en caso contrario.
        Ejemplo:
            Para seleccionar el primer elemento: SetItemState(0, 1, 1)
            Para de-seleccionar el quinto elemento: SetItemState(4, 0, 1)  ; 1 indica que se va a modificar únicamente el estado TCIS_BUTTONPRESSED, 0 desactivaría el estado TCIS_BUTTONPRESSED
            Para quitar todos los estados del tercer elemento: SetItemState(2, 0, 1|2)    ; 1|2 indica los estados que se van a modificar TCIS_BUTTONPRESSED|TCIS_HIGHLIGHTED
            Para resaltar y quitar la selección del segundo elemento: SetItemState(1, 2)  ; el tercer parámetro es opcional, por defecto es 3, que es lo mismo que 1|2
    */
    SetItemState(Item, State, StateMask := 3)
    {
        ; TCM_SETITEM message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-setitem
        NumPut(StateMask, NumPut(State, NumPut(0x10, this.ptr, "UInt"), "UInt"), "UInt")
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x133D, "Ptr", Item, "UPtr", this.ptr)
    }

    /*
        Recupera el número de elementos actualmente en el control.
    */
    GetCount()
    {
        ; TCM_GETITEMCOUNT message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-getitemcount
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x1304, "Ptr", 0, "Ptr", 0, "Ptr")
    }

    /*
        Recupera el número de filas actualmente en el control.
        Solo los controles Tab que tienen el estilo TCS_MULTILINE pueden tener varias filas de pestañas.
    */
    GetRowCount()
    {
        ; TCM_GETROWCOUNT message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-getrowcount
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x132C, "Ptr", 0, "Ptr", 0, "Ptr")
    }

    /*
        Elimina el elemento especificado.
        Return:
            Devuelve un valor distinto de cero si tuvo éxito.
    */
    Delete(Item)
    {
        ; TCM_DELETEITEM message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-deleteitem
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x1308, "Ptr", Item, "Ptr", 0)
    }

    /*
        Elimina todos los elementos.
        Return:
            Devuelve un valor distinto de cero si tuvo éxito.
    */
    DeleteAll()
    {
        ; TCM_DELETEALLITEMS message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-deleteallitems
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x1309, "Ptr", 0, "Ptr", 0)
    }

    /*
        Selecciona el elemento especificado. Por defecto este método quita la selección actual.
        Parámetros:
            Item:
                El índice basado en cero del elemento a seleccionar, o -1 para quitar toda selección.
            DeselectAll:
                Quita cualquier selección antes de establecer el elemento especificado como seleccionado.
        Return:
            Devuelve el índice del elemento seleccionado previamente si tiene éxito, o -1 en caso contrario.
        Observaciones:
            Un elemento puede estar seleccionado y no tener el foco. La selección solo es útil si el control tiene el estilo TCS_BUTTONS (0x100).
            Debe añadir el estilo TCS_MULTISELECT (0x4) para permitir la selección de múltiples elementos.
    */
    SetCurSel(Item := -1, DeselectAll := FALSE)
    {
        if (Item == -1 || DeselectAll)
            ; TCM_DESELECTALL message
            ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-deselectall
            DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x1332, "Ptr", 0, "Ptr", 0)
        if (Item != -1)
            ; TCM_SETCURSEL message
            ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-setcursel
            return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x130C, "Ptr", Item, "Ptr", 0, "Ptr")
    }

    /*
        Recupera el índice basado en cero del elemento actualmente seleccionado.
        Return:
            Devuelve un Array con el índice basado en cero de los elementos actualmente seleccionados.
            Si no hay elementos actualmente seleccionados devuelve un Array vacío (longitud cero).
    */
    GetCurSel()
    {
        local arr := []
        Loop (this.GetCount())
            if (this.GetItemState(A_Index-1) & 0x1)
                ObjPush(arr, A_Index-1)
        return arr
    }

    /*
        Encuentra el índice basado en cero del primer elemento cuyo texto que coincide con la cadena especificada.
        Parámetros: 
            Text:
                El texto del elemento que se va a buscar.
            Item:
                El índice basado en cero del elemento desde el cual empezar a buscar (inclusive).
                Cuando la búsqueda llega al final, continúa desde la parte superior hasta el elemento especificado.
                Puede especificar un objeto con las claves Start y End que especifican el rango exacto en el que realizar la búsqueda.
            Mode:
                Determina el comportamiento de la búsqueda. Debe especificar uno de los siguientes valores.
                0 = Busca el elemento cuyo texto coincide exactamente con la cadena especificada. Este es el modo por defecto.
                1 = Busca el elemento cuyo texto comience por la cadena especificada. 
                2 = Busca el elemento cuyo texto coincida de forma parcial con la cadena especificada.
            CaseSensitive:
                Especifica si la búsqueda distingue entre minúsculas y mayúsculas. Por defecto es cero (FALSE).
            Length:
                La cantidad de caracteres que se va a recuperar al realizar la comparación. Este parámetro solo es válido con los modos 0 y 2.
        Return:
            El valor de retorno es el índice basado en cero del elemento coincidente. -1 si la búsqueda no ha tenido éxito.
    */
    FindString(Text, Item := 0, Mode := 0, CaseSensitive := FALSE, Length := 1000)
    {
        local len := StrLen(Text), itm := IsObject(Item) ? Item : {start: Item, end: -1}
        Loop (this.GetCount())
        {
            if (A_Index - 1 < itm.start)
                continue
            if (A_Index - 1 == itm.end)
                break
            if (Mode == 2 && InStr(this.GetText(A_Index-1,Length), Text, CaseSensitive))
            || (Mode != 2 && ( (CaseSensitive  && Text == this.GetText(A_Index-1,Mode?len:Length))
                          ||   (!CaseSensitive && Text  = this.GetText(A_Index-1,Mode?len:Length)) ))
                return A_Index - 1
        }
        return IsObject(Item) ? -1 : this.FindString(Text, {start: 0, end: itm.start}, Mode, CaseSensitive)
    }

    /*
        Calcula el área de visualización dado un rectángulo o calcula el rectángulo que correspondería a un área de visualización específica.
        Parámetros:
            Operation:
                Si este parámetro es 1 (TRUE), el parámetro «Rect» especifica un rectángulo de visualización y recibe el rectángulo de ventana correspondiente.
                Si este parámetro es 0 (FALSE), el parámetrp «Rect» especifica un rectángulo de ventana y recibe el área de visualización correspondiente.
            Rect:
                Puntero a una estructura RECT que especifica el rectángulo dado y recibe el rectángulo calculado. También puede especificar un objeto con las claves L(eft), T(op), R(ight) y B(ottom).
        Return:
            Devuelve un objeto con las claves L(eft), T(op), R(ight) y B(ottom).
        Observaciones:
            Este mensaje se aplica solo a los controles de pestañas que se encuentran en la parte superior. No se aplica a los controles de pestañas que están en los lados o en la parte inferior.
    */
    AdjustRect(Operation, Rect)
    {
        if (IsObject(Rect))
            NumPut(Rect.L, this.ptr, "Int"), NumPut(Rect.T, this.ptr+4, "Int")
          , NumPut(Rect.R, this.ptr+8, "Int"), NumPut(Rect.B, this.ptr+12, "Int"), Rect := this.ptr
        ; TCM_ADJUSTRECT message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-adjustrect
        DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x1328, "Ptr", Operation, "UPtr", Rect)
        return {L: NumGet(Rect, "Int"), T: NumGet(Rect+4, "Int"), R: NumGet(Rect+8, "Int"), B: NumGet(Rect+12, "Int")}
    }

    /*
        Recupera las coordenadas y dimensiones del área de visualización del control (esta es el área en "blanco" donde añadir controles).
        Parámetros:
            LeftMargin / TopMargin:
                El margen izquierdo y superior respectivamente. Por defecto tiene un margen de 5 y 7 píxeles.
            RightMargin / BottomMargin:
                El margen derecho e inferior respectivamente. Por defecto tiene un margen de 12 y 13 píxeles.
        Return:
            Devuelve un objeto con las claves GX, GY, X, Y, W(idth) y H(eight). GX y GY representan las coordenadas relativas a la ventana GUI.
    */
    GetDisplayArea(LeftMargin := 5, TopMargin := 7, RightMargin := 12, BottomMargin := 13)
    {
        local rect := this.AdjustRect(0, {L: 0, T: 0, R: this.pos.w, B: this.pos.h})
        return {X: rect.l+LeftMargin, Y: rect.t+TopMargin, GX: this.pos.x+rect.l+LeftMargin, GY: this.pos.y+rect.t+TopMargin, W: rect.r-rect.l-RightMargin, H: rect.b-rect.t-BottomMargin}
    }

    /*
        Establece la pestaña a utilizar para los nuevos controles.
        Parámetros:
            Tab:
                Si es un entero especifica el índice basado en cero de la pestaña a utilizar. -1 para desactivar.
                Si es una cadena especifica el texto de la pestaña a utilizar.
            Mode / CaseSensitive / Item:
                El modo de búsqueda cuando el parámetro «Tab» es un cadena. Ver Tab::FindString.
        Return:
            Si tuvo éxito devuelve 1 (TRUE), o cero en caso de que el elemento no se haya podido encontrar.
    */
    UseTab(Tab := -1, Mode := 0, CaseSensitive := FALSE, Item := 0)
    {
        if (Tab == -1)
            this.ctrl.UseTab()
        else
        {
            Tab := Type(Tab) = "integer" ? Tab : this.FindString(Tab, Item, Mode, CaseSensitive)
            if (Tab < 0 || Tab >= this.GetCount())
                return FALSE
            this.ctrl.UseTab(Tab+1)
        }
        return TRUE
    }

    /*
        Establece el ancho y el alto de los elementos. El ancho solo es válido si el control tiene el estilo de ancho fijo TCS_FIXEDWIDTH (0x400).
        Parámetros:
            Width / Heigt:
                El nuevo ancho y alto respectivamente para todos los elementos en el control.
        Return:
            Devuelve un objeto con las claves «W» y «H» con el ancho y alto anterior respectivamente.
    */
    SetItemSize(Width, Height)
    {
        ; TCM_SETITEMSIZE message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-setitemsize
        local ret := DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x1329, "Ptr", 0, "Ptr", (Width&0xFFFF)|((Height&0xFFFF)<<16), "Ptr")
        return {W: ret & 0xFFFF, H: (ret >> 16) & 0xFFFF}
    }

    /*
        Recupera el rectángulo delimitador del elemento especificado.
        Return:
            Si tuvo éxito devuelve un objeto con las claves L(eft)|T(op)|R(ight)|B(ottom), o cero en caso contrario.
    */
    GetItemRect(Item)
    {
        ; TCM_GETITEMRECT message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-getitemrect
        local ret := DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x130A, "Ptr", Item, "UPtr", this.ptr)
        return ret ? {L: NumGet(this.ptr, "Int"), T: NumGet(this.ptr+4, "Int"), R: NumGet(this.ptr+8, "Int"), B: NumGet(this.ptr+12, "Int")} : 0
    }

    /*
        Establece el ancho mínimo de elementos en el control de pestañas.
        Parámetros:
            Width:
                Ancho mínimo que se establecerá para un elemento de control de pestañas. Si este parámetro se establece en -1, el control usará el ancho de pestaña predeterminado.
        Return:
            Devuelve un valor que representa el ancho de pestaña mínimo anterior.
    */
    SetMinWidth(Width)
    {
        ; TCM_SETMINTABWIDTH message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-setmintabwidth
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x1331, "Ptr", 0, "Ptr", Width)
    }

    /*
        Recupera la lista de imágenes asociada con el control de pestañas.
        Return:
            Devuelve el identificador a la lista de imágenes si es exitoso, o cero de lo contrario. 
    */
    GetImageList()
    {
        ; TCM_GETIMAGELIST message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-getimagelist
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x1302, "Ptr", 0, "Ptr", 0, "Ptr")
    }

    /*
        Asigna una lista de imágenes al control de pestañas.
        Parámetros:
            ImageList:
                Identificador a la lista de imágenes para asignarla al control de pestañas.
        Return:
            Devuelve el identificador a la lista de imágenes anterior, o cero si no hay una lista de imágenes previa.
    */
    SetImageList(ImageList)
    {
        ; TCM_SETIMAGELIST message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-setimagelist
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x1303, "Ptr", 0, "Ptr", ImageList, "Ptr")
    }

    /*
        Establece la cantidad de espacio (relleno) alrededor del icono y la etiqueta de cada pestaña en el control de pestañas.
        Parámetros:
            Horizontal / Vertical:
                Especifica la cantidad de relleno horizontal y vertical respectivamente, en píxeles.
    */
    SetPadding(Horizontal, Vertical)
    {
        ; TCM_SETPADDING message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-setpadding
        DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x132B, "Ptr", 0, "Ptr", (Horizontal&0xFFFF)|((Vertical&0xFFFF)<<16))
    }

    /*
        Determina qué pestaña, si hay alguna, está en una posición en la pantalla especificada.
        Parámetros:
            X / Y:
                Las coordenadas relativas al control que representan la posición a probar.
                Si es una cadena vacía, usa la ubicación actual del cursor.
        Return:
            Devuelve un objeto con las siguientes claves.
            Item = Índice en base cero del elemento en las coordenadas especificadas, o -1 si no hay ningún elemento en esas coordenadas.
            Pos  = Recibe un número entero con información adicional. Se establece en uno de los siguientes valores.
                1 (TCHT_NOWHERE)     = La posición no está sobre una pestaña.
                2 (TCHT_ONITEMICON)  = La posición está sobre el ícono de una pestaña.
                4 (TCHT_ONITEMLABEL) = La posición está sobre el texto de una pestaña.
                6 (TCHT_ONITEM)      = La posición está sobre una pestaña, pero no sobre su icono o su texto. Para los controles de pestaña dibujados por el propietario, este valor se especifica si la posición está en cualquier lugar sobre una pestaña.
    */
    HitTest(X := "", Y := "")
    {
        if (X == "" || Y == "")
            DllCall("User32.dll\GetCursorPos", "UPtr", this.ptr)
          , DllCall("User32.dll\ScreenToClient", "Ptr", this.hWnd, "UPtr", this.ptr)
        ; TCM_HITTEST message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-hittest
        X := X == "" ? X : NumPut(X, this.ptr, "Int"), Y := Y == "" ? Y : NumPut(Y, this.ptr+4, "Int")
        local index := DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x130D, "Ptr", 0, "UPtr", this.ptr, "Ptr")
        return {Item: index, Pos: NumGet(this.ptr+8, "UInt")}
    }

    /*
        Vuelve a dibujar el área ocupada por el control.
    */
    Redraw()
    {
        ; InvalidateRect function
        ; https://docs.microsoft.com/es-es/windows/desktop/api/winuser/nf-winuser-invalidaterect
        return DllCall("User32.dll\InvalidateRect", "Ptr", this.hWnd, "UPtr", 0, "Int", TRUE)
    }

    /*
        Establece el foco del teclado en el control.
    */
    Focus()
    {
        this.ctrl.Focus()
    }

    /*
        Cambia la fuente.
    */
    SetFont(Options, FontName := "")
    {
        this.ctrl.SetFont(Options, FontName)
    }

    /*
        Mueve y/o cambia el tamaño del control, opcionalmente lo vuelve a dibujar.
    */
    Move(Pos, Draw := FALSE)
    {
        this.ctrl.Move(Pos, Draw)
    }


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Recupera o establece el índice basado en cero del elemento que tiene actualmente el foco.
        get:
            Devuelve el índice basado en cero del elemento que tiene el foco.
        set:
            Deselecciona todos los elementos actualmente en selección y establece la selección en el elemento especificado.
            Devuelve el índice basado en cero del elemento que tiene el foco luego de establecerlo.
    */
    Selected[]
    {
        get {
            ; TCM_GETCURFOCUS message
            ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-getcurfocus
            return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x132F, "Ptr", 0, "Ptr", 0, "Ptr")
        }
        set {
            this.SetCurSel(-1), this.SetCurSel(value)
            ; TCM_SETCURFOCUS message
            ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-setcurfocus
            DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x1330, "Ptr", value, "Ptr", 0)
            return this.Focused
        }
    }

    /*
        Recupera o establece los estilos extendidos que están en uso en el control.
        https://docs.microsoft.com/es-es/windows/desktop/Controls/tab-control-extended-styles
        set:
            Devuelve un valor que contiene los estilos extendidos previamente utilizados para el control.
    */
    ExStyle[]
    {
        get {
            ; TCM_GETEXTENDEDSTYLE message
            ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-getextendedstyle
            return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x1335, "Ptr", 0, "Ptr", 0, "UInt")
        }
        set {
            ; TCM_SETEXTENDEDSTYLE message
            ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tcm-setextendedstyle
            return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x1334, "UInt", 3, "UInt", value, "UInt")
        }
    }

    /*
        Recupera la posición y dimensiones del control.
    */
    Pos[]
    {
        get {
            return this.ctrl.Pos
        }
    }

    /*
        Determina si el control tiene el foco del teclado.
    */
    Focused[]
    {
        get {
            return this.ctrl.Focused
        }
    }

    /*
        Recupera o establece el estado de visibilidad del control.
        get:
            Devuelve cero si la ventana no es visible, 1 en caso contrario.
        set:
            Si la ventana estaba visible anteriormente, el valor de retorno es distinto de cero.
            Si la ventana estaba previamente oculta, el valor de retorno es cero.
    */
    Visible[]
    {
        get {
            ; IsWindowVisible function
            ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms633530(v=vs.85).aspx
            return DllCall("User32.dll\IsWindowVisible", "Ptr", this.hWnd)
        }
        set {
            ; ShowWindow function
            ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms633548(v=vs.85).aspx
            return DllCall("User32.dll\ShowWindow", "Ptr", this.hWnd, "Int", Value ? 8 : 0)
        }
    }

    /*
        Recupera o establece el estado habilitado/deshabilitado del control.
        get:
            Si la ventana esta habilitada devuelve un valor distinto de cero, o cero en caso contrario.
        set:
            Si la ventana estaba deshabilitada, el valor de retorno es distinto de cero.
            Si la ventana estaba habilitada, el valor de retorno es cero.
    */
    Enabled[]
    {
        get {
            ; IsWindowEnabled function
            ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms646303(v=vs.85).aspx
            return DllCall("User32.dll\IsWindowEnabled", "Ptr", this.hWnd)
        }
        set {
            ; EnableWindow function
            ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms646291(v=vs.85).aspx
            return DllCall("User32.dll\EnableWindow", "Ptr", this.hWnd, "Int", !!Value)
        }
    }
}

TabCreate(Gui, Options := "", Items*)
{
    return new Tab(Gui, Options, Items*)
}
