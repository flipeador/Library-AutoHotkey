# Subprocess::IsWow64Process method

Determines whether the child process is running under WOW64 or an Intel64 of x64 processor.




### Syntax

```
int IsWow64Process()
```




### Return value

If the method succeeds, the return value is one of the following:

| Value | Description |
| -------- | -------- |
| TRUE | The process is running under WOW64 on an Intel64 or x64 processor. |
| FALSE | The process is running under 32-bit Windows.<br>The process is a 32-bit application running under 64-bit Windows 10 on ARM.<br>The process is a 64-bit application running under 64-bit Windows. |

If the function fails, an exception is thrown. To get extended error information, check `A_LastError`.




### Remarks

This method can be useful if the process was created with the `CREATE_SUSPENDED` creation flag.




### References

- [IsWow64Process function | Microsoft](https://docs.microsoft.com/en-us/windows/desktop/api/wow64apiset/nf-wow64apiset-iswow64process).
