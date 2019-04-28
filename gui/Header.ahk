/*
Gui := GuiCreate()
Trv := Gui.AddTreeView("x5 y5 w500 h350")
HDR := new Header(Gui, "x0 y0 w500 h30 +0x2 +0x4 +0x40 +0x80", "ID", "String", "Integer", "Float")
    DllCall("User32.dll\SetParent", "Ptr", HDR.Hwnd, "Ptr", Trv.Hwnd, "Ptr")

Loop 100
    Trv.Add("Item #" . A_Index)

Gui.Show("w510 h360")
    Gui.OnEvent("Close", "ExitApp")
Return
*/




; ********** SIN TERMINAR ********** UNFINISHED **********

Class Header
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES
    ; ===================================================================================================================
    static CtrlList := {}    ; almacena una lista con todos los controles Toolbar {ControlID:ToolbarObj}


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    /*
        Añade un control de encabezado en la ventana GUI especificada.
        Parámetros:
            Gui:
                El objeto de ventana GUI. También puede especificar un objeto control existente (o su identificador).
            Options:
                Las opciones para el nuevo control. A continuación se describen las opciones especiales para este tipo de control: "https://docs.microsoft.com/es-es/windows/desktop/Controls/header-control-styles".
                0x0002 (HDS_BUTTONS)    = Cada elemento en el control se ve y se comporta como un botón. Este estilo es útil si una aplicación realiza una tarea cuando el usuario hace clic en un elemento del encabezado. Por ejemplo, una aplicación podría ordenar la información en las columnas de manera diferente según el elemento en el que haga clic el usuario.
                0x0004 (HDS_HOTTRACK)   = Habilita el seguimiento en caliente.
                0x0008 (HDS_HIDDEN)     = Indica un control de encabezado que está destinado a ocultarse. Este estilo no oculta el control.
                0x0040 (HDS_DRAGDROP)   = Permite reordenar arrastrando y soltando elementos del encabezado.
                0x0080 (HDS_FULLDRAG)   = Hace que el control de encabezado muestre el contenido de la columna incluso cuando el usuario cambia el tamaño de una columna.
                0x0100 (HDS_FILTERBAR)  = Incluya una barra de filtro como parte del control de encabezado estándar. Esta barra permite a los usuarios aplicar convenientemente un filtro a la pantalla.
                0x0200 (HDS_FLAT)       = Hace que el control del encabezado se dibuje plano cuando el sistema operativo se ejecuta en modo clásico.
                0x0400 (HDS_CHECKBOXES) = Permite la colocación de casillas de verificación en los artículos del encabezado.
                0x0800 (HDS_NOSIZING)   = El usuario no puede arrastrar el divisor en el control del encabezado.
                0x1000 (HDS_OVERFLOW)   = Se muestra un botón cuando no se pueden mostrar todos los elementos dentro del rectángulo del control del encabezado.
    */
    __New(Gui, Options, Items*)
    {
        if (Type(Gui) != "Gui")
        {
            Gui := IsObject(Gui) ? Gui.Hwnd : Gui
            local hWnd := 0, obj := ""
            For hWnd, obj in Toolbar.CtrlList
                if (hWnd == Gui)
                    return obj
            return 0
        }

        ; Header Control Reference
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/bumper-header-control-header-control-reference
        this.ctrl := Gui.AddCustom("ClassSysHeader32 " . Options)
        this.hWnd := this.ctrl.Hwnd
        this.gui  := Gui
        this.Type := "Header"

        this.Buffer := ""
        ObjSetCapacity(this, "Buffer", 72)
        this.ptr := ObjGetAddress(this, "Buffer")

        if (ObjLength(Items))
        {
            local width := 0
            width := this.ctrl.pos.w // (RegExMatch(Options, "i)\bR(\d+)\b", width) ? width[1] : ObjLength(Items))
            Loop (ObjLength(Items))
                this.Add(, String(Items[A_Index]), width)
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
        ObjDelete(Header.CtrlList, this.hWnd)
        DllCall("User32.dll\DestroyWindow", "Ptr", this.hWnd)
    }

    /*
        Añade un elemento en la posición especificada.
        Parámetros:
            Item:
                El índice basado en cero del nuevo elemento. Para insertar un elemento al final de la lista, establezca el parámetro en -1.
            Text:
                El texto a mostrar en el elemento. Si especifica un valor de tipo entero se tomará como una dirección de memoria.
            Width:
                El ancho del elemento, en píxeles. Por defecto este valor es cero.
            Format:
                Indicadores que especifican el formato del elemento. Por defecto los contenidos del elemento están alineados a la izquierda.
                0x001 (HDF_RIGHT)      = Los contenidos del elemento están alineados a la derecha.
                0x002 (HDF_CENTER)     = Los contenidos del elemento están centrados.
                0x040 (HDF_CHECKBOX)   = El elemento muestra una casilla de verificación. Este valor es válido si el control tiene el estilo HDS_CHECKBOXES.
                0x080 (HDF_CHECKED)    = El elemento muestra una casilla de verificación marcada. Este valor es válido si el control tiene el estilo HDS_CHECKBOXES.
                0x100 (HDF_FIXEDWIDTH) = El ancho del elemento no puede ser modificado por una acción del usuario para cambiar su tamaño.
            Image:
                El índice basado en cero de una imagen dentro de la lista de imágenes. El valor -2 indica que el botón no debe mostrar ninguna imagen (este es el valor por defecto).
            Data:
                Datos de elementos definidos por la aplicación. Debe especificar un número de tipo entero con signo.
        Return:
            Devuelve el índice del nuevo elemento si tiene éxito, o -1 en caso contrario.
    */
    Add(Item := -1, Text := "", Width := 0, Format := 0, Image := -2, Data := 0)
    {
        ; HDM_INSERTITEM message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/hdm-insertitem
        NumPut(1 | 2 | 4 | 8 | 0x20, this.ptr, "UInt")    ; HDI_WIDTH | HDI_TEXT | HDI_FORMAT | HDI_LPARAM | HDI_IMAGE
      , NumPut(Width, this.ptr+4, "Int")
      , NumPut(Type(Text) == "Integer" ? Text : &Text, this.ptr+8, "Int")
      , NumPut(Format, this.ptr+12+2*A_PtrSize, "Int")
      , NumPut(Data, this.ptr+16+2*A_PtrSize, "Ptr")
      , NumPut(Image, this.ptr+16+3*A_PtrSize, "Int")
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x120A, "Ptr", Item == -1 ? this.GetCount() : Item, "UPtr", this.ptr, "Ptr")
    }

    /*
        Recupera la cantidad de elementos actualmente en el control de encabezado.
    */
    GetCount()
    {
        ; HDM_GETITEMCOUNT message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/hdm-getitemcount
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x1200, "Ptr", 0, "Ptr", 0, "Ptr")
    }
}
