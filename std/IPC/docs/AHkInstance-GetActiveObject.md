# Static AHkInstance::GetActiveObject method

Gets the registered active object of the specified subprocess.




### Syntax

```
Client GetActiveObject(
  IN String Name
)
```




### Parameters

###### Name

The name of the AHkInstance object from which the [Client](Client.md) object is to be retrieved.




### Return value

If the method was successful, returns a [Client](Client.md) object.

If the method was not successful, the return value is zero.
