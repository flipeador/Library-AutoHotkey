/*
    Initializes the opaque OBJECT_ATTRIBUTES structure, which specifies the properties of an object handle to routines that open handles.
    Parameters:
        ObjectName:
            A pointer to a Unicode string that contains name of the object for which a handle is to be opened.
            This must either be a fully qualified object name, or a relative path name to the object directory specified by the RootDirectory parameter.
        Attributes:
            Specifies one or more of the following flags:
            0x00000002  OBJ_INHERIT               This handle can be inherited by child processes of the current process.
            0x00000010  OBJ_PERMANENT             This flag only applies to objects that are named within the object manager.
                                                  By default, such objects are deleted when all open handles to them are closed.
                                                  If this flag is specified, the object is not deleted when all open handles are closed.
                                                  Drivers can use ZwMakeTemporaryObject to delete permanent objects.
            0x00000020  OBJ_EXCLUSIVE             Only a single handle can be open for this object.
            0x00000040  OBJ_CASE_INSENSITIVE      A case-insensitive comparison is used when matching the ObjectName parameter against the names of existing objects.
                                                  Otherwise, object names are compared using the default system settings.
            0x00000080  OBJ_OPENIF                If this flag is specified to a routine that creates objects, and that object already exists then the routine should open that object.
                                                  Otherwise, the routine creating the object returns an NTSTATUS code of STATUS_OBJECT_NAME_COLLISION.
            0x00000200  OBJ_KERNEL_HANDLE         Specifies that the handle can only be accessed in kernel mode.
            0x00000400  OBJ_FORCE_ACCESS_CHECK    The routine opening the handle should enforce all access checks for the object, even if the handle is being opened in kernel mode.
        RootDirectory:
            A handle to the root object directory for the path name specified in the ObjectName parameter.
            If ObjectName is a fully qualified object name, RootDirectory is NULL. Use ZwCreateDirectoryObject to obtain a handle to an object directory.
        SecurityDescriptor:
            Specifies a security descriptor to apply to an object when it is created.
            This parameter is optional. Drivers can specify NULL to accept the default security for the object.
        SecurityQualityOfService:
            Optional quality of service to be applied to the object when it is created.
            Used to indicate the security impersonation level and context tracking mode (dynamic or static).
    Return value:
        The return value is a Buffer object representing a OBJECT_ATTRIBUTES structure.
*/  
InitObjAttributes(ObjectName := 0, Attributes := 0, RootDirectory := 0, SecurityDescriptor := 0, SecurityQualityOfService := 0)
{
    local Buffer := BufferAlloc(6*A_PtrSize)
    NumPut("UInt", Buffer.Size, Buffer)                            ; ULONG           Length.
    NumPut("UPtr", RootDirectory                                   ; HANDLE          RootDirectory.
         , "UPtr", ObjectName                                      ; PUNICODE_STRING ObjectName.
         , "UInt", Attributes, Buffer, A_PtrSize)                  ; ULONG           Attributes.
    NumPut("UPtr", SecurityDescriptor                              ; PVOID           SecurityDescriptor.
         , "UPtr", SecurityQualityOfService, Buffer, 4*A_PtrSize)  ; PVOID           SecurityQualityOfService
    return Buffer
} ; https://technet.microsoft.com/zh-cn/ff547804%28v=vs.94%29?f=255&MSPPError=-2147217396
