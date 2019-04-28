# Subprocess::Close method

Closes all open Handles and releases the used resources.




### Syntax

```
void Close()
```




### Return value

This method does not return a value.




### Remarks

Once this method returns, this class object becomes unusable.

This method also calls the [UnregisterWait](Subprocess-UnregisterWait.md) method.

Calling this method does not terminate the process.
