IUIAutomation()
{
    Return (New __Class_IUIAutomation)
}




Class __Class_IUIAutomation
{
    Ptr := 0

    __New()
    {
        This.Ptr := ComObjCreate('{FF48DBA4-60EF-4201-AA87-54103EEF594E}', '{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}')
        If (!This.Ptr)
            Return (FALSE)
    }

    __Delete()
    {
        ObjRelease(This.Ptr)
    }

    /*
        IUIAutomation::ElementFromPoint
    */
    ElementFromPoint(X, Y)
    {
        DllCall(NumGet(NumGet(This.Ptr, 0, 'Ptr'), 7*A_PtrSize, 'Ptr'), 'Ptr', This.Ptr, 'Int64', X|Y<<32, 'PtrP', pElement, 'UInt')
        Return (pElement ? New __Class_IUIAutomationElement(pElement) : 0)
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/ee671538(v=vs.85).aspx

    /*
        IUIAutomation::GetRootElement
    */
    GetRootElement()
    {
        DllCall(NumGet(NumGet(This.Ptr, 0, 'Ptr'), 5*A_PtrSize, 'Ptr'), 'Ptr', This.Ptr, 'PtrP', pElement, 'UInt')
        Return (pElement ? New __Class_IUIAutomationElement(pElement) : 0)
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/ee671544(v=vs.85).aspx

    /*
        IUIAutomation::CompareElements
    */
    CompareElements(Element1, Element2)
    {
        DllCall(NumGet(NumGet(This.Ptr, 0, 'Ptr'), 3*A_PtrSize, 'Ptr'), 'Ptr', This.Ptr, 'Ptr', Element1.Ptr, 'Ptr', Element2.Ptr, 'IntP', AreSame, 'UInt')
        Return (AreSame)
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/ee671514(v=vs.85).aspx

    /*
        IUIAutomation::CreateTrueCondition
    */
    CreateTrueCondition()
    {
        DllCall(NumGet(NumGet(This.Ptr, 0, 'Ptr'), 21*A_PtrSize, 'Ptr'), 'Ptr', This.Ptr, 'PtrP', pCondition, 'UInt')
        Return (pCondition ? New __Class_IUIAutomationCondition(pCondition) : 0)
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/ee671533(v=vs.85).aspx

    /*
        IUIAutomation::ControlViewWalker
    */
    ControlViewWalker()
    {
        DllCall(NumGet(NumGet(This.Ptr, 0, 'Ptr'), 21*A_PtrSize, 'Ptr'), 'Ptr', This.Ptr, 'PtrP', pTreeWalker, 'UInt')
        Return (pTreeWalker ? New __Class_IUIAutomationTreeWalker(pTreeWalker) : 0)
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/ee671519(v=vs.85).aspx
}




Class __Class_IUIAutomationTreeWalker
{
    Ptr := 0

    __New(pTreeWalker)
    {
        This.Ptr := pTreeWalker
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/ee671470(v=vs.85).aspx

    __Delete()
    {
        ObjRelease(This.Ptr)
    }

    /*
        IUIAutomationTreeWalker::GetParentElement
    */
    GetParentElement(Element)
    {
        DllCall(NumGet(NumGet(This.Ptr, 0, 'Ptr'), 3*A_PtrSize, 'Ptr'), 'Ptr', This.Ptr, 'Ptr', Element.Ptr, 'PtrP', pElement, 'UInt')
        Return (pElement ? New __Class_IUIAutomationElement(pElement) : 0)
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/ee671478(v=vs.85).aspx
}




Class __Class_IUIAutomationCondition
{
    Ptr := 0

    __New(pCondition)
    {
        This.Ptr := pCondition
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/ee671420(v=vs.85).aspx

    __Delete()
    {
        ObjRelease(This.Ptr)
    }
}




Class __Class_IUIAutomationElement
{
    Ptr := 0

    __New(pElement)
    {
        This.Ptr := pElement
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/ee671425(v=vs.85).aspx

    __Delete()
    {
        ObjRelease(This.Ptr)
    }

    /*
        IUIAutomationElement::CurrentName
    */
    CurrentName()
    {
        DllCall(NumGet(NumGet(This.Ptr, 0, 'Ptr'), 23*A_PtrSize, 'Ptr'), 'Ptr', This.Ptr, 'PtrP', pName, 'UInt')
        Return (pName ? StrGet(pName, 'UTF-16') : '')
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/ee696022(v=vs.85).aspx

    /*
        IUIAutomationElement::GetCurrentPropertyValue
    */
    GetCurrentPropertyValue(Value)
    {
        Variant := New __Class_IUIAutomation_VARIANT()

        R := DllCall(NumGet(NumGet(This.Ptr, 0, 'Ptr'), 10*A_PtrSize, 'Ptr'), 'Ptr', This.Ptr, 'UInt', Value, 'Ptr', Variant.Ptr, 'UInt')
        Return (R ? 0 : Variant)
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/ee696040(v=vs.85).aspx

    /*
        IUIAutomationElement::CurrentControlType
    */
    CurrentControlType()
    {
        DllCall(NumGet(NumGet(This.Ptr, 0, 'Ptr'), 21*A_PtrSize, 'Ptr'), 'Ptr', This.Ptr, 'UIntP', ControlType, 'UInt')
        Return (ControlType)
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/ee696003(v=vs.85).aspx

    /*
        IUIAutomationElement::FindAll
    */
    FindAll(Condition)
    {
        DllCall(NumGet(NumGet(This.Ptr, 0, 'Ptr'), 6*A_PtrSize, 'Ptr'), 'Ptr', This.Ptr, 'UInt', 2, 'Ptr', Condition.Ptr, 'PtrP', pElementArray, 'UInt')
        Return (pElementArray ? New __Class_IUIAutomationElementArray(pElementArray) : 0)
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/ee696027(v=vs.85).aspx
}




Class __Class_IUIAutomation_VARIANT
{
    Ptr := 0

    __New(Type := 0, Value := 0)
    {
        This.Ptr := DllCall('Kernel32.dll\GlobalAlloc', 'UInt', 0x40, 'UPtr', 8 + 2*A_PtrSize, 'UPtr')

        NumPut(Type, This.Ptr, 0, 'UShort')
        NumPut(Value, This.Ptr, 8, 'Ptr')
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms221627(v=vs.85).aspx

    __Delete()
    {
        DllCall('Kernel32.dll\GlobalFree', 'UPtr', This.Ptr, 'UPtr')
    }

    Type[]
    {
        Get
        {
            Return (NumGet(This.Ptr, 0, 'UShort'))
        }

        Set
        {
            NumPut(Value, This.Ptr, 0, 'UShort')
        }
    }

    Value[]
    {
        Get
        {
            Return (NumGet(This.Ptr, 8, 'Ptr'))
        }

        Set
        {
            NumPut(Value, This.Ptr, 8, 'Ptr')
        }
    }

    String[]
    {
        Get
        {
            Ptr := NumGet(This.Ptr, 8, 'Ptr')
            Return (Ptr ? StrGet(Ptr, 'UTF-16') : '')
        }
    }
}




Class __Class_IUIAutomationElementArray
{
    Ptr := 0

    __New(pElementArray)
    {
        This.Ptr := pElementArray
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/ee671426(v=vs.85).aspx

    __Delete()
    {
        ObjRelease(This.Ptr)
    }

    /*
        IUIAutomationElementArray::Length
    */
    Length()
    {
        DllCall(NumGet(NumGet(This.Ptr, 0, 'Ptr'), 3*A_PtrSize, 'Ptr'), 'Ptr', This.Ptr, 'IntP', Length, 'UInt')
        Return (Length)
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/ee671428(v=vs.85).aspx
}






    /*
    If (Element.CurrentControlType() == 50004)
    {
        Walker := UIA.ControlViewWalker()
        If (ParentElement := Walker.GetParentElement(Element))
        {  
            R.Push('IS EDIT!')
        }
    }

GetElementWhole(element){
    global uia
    static init:=1,trueCondition,walker
    if init
        init:=DllCall(vt(uia,21),"ptr",uia,"ptr*",trueCondition) ;IUIAutomation::CreateTrueCondition
        ,init+=DllCall(vt(uia,14),"ptr",uia,"ptr*",walker) ;IUIAutomation::ControlViewWalker
    DllCall(vt(uia,5),"ptr",uia,"ptr*",root) ;IUIAutomation::GetRootElement
    DllCall(vt(uia,3),"ptr",uia,"ptr",element,"ptr",root,"int*",same) ;IUIAutomation::CompareElements
    ObjRelease(root)
    if same {
        return
    }
    hr:=DllCall(vt(walker,3),"ptr",walker,"ptr",element,"ptr*",parent) ;IUIAutomationTreeWalker::GetParentElement
    MsgBox % parent
    if parent {
        e:=""
        DllCall(vt(parent,6),"ptr",parent,"uint",2,"ptr",trueCondition,"ptr*",array) ;IUIAutomationElement::FindAll
        DllCall(vt(array,3),"ptr",array,"int*",length) ;IUIAutomationElementArray::Length
        loop % length {
            DllCall(vt(array,4),"ptr",array,"int",A_Index-1,"ptr*",newElement) ;IUIAutomationElementArray::GetElement
            DllCall(vt(newElement,23),"ptr",newElement,"ptr*",name) ;IUIAutomationElement::CurrentName
            e.=StrGet(name,"utf-16")
            ObjRelease(newElement)
        }
                ObjRelease(array)
        ObjRelease(parent)
        return e
    }
}
    */