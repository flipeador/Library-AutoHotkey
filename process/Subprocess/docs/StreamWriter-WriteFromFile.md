# Subprocess::Pipe::StreamWriter::WriteFromFile method

Write raw binary data from a file to the pipe.




### Syntax

```
int WriteFromFile(
  IN File/String File,
  IN Integer Bytes = -1,
  IN String Encoding = ""
)
```




### Parameters

###### File

A filename or a file object with read access.

###### Bytes

The number of bytes to write.

If this parameter is `-1`, the whole file is read.

###### Encoding

The code page to use for text I/O if the file does not contain a `UTF-8` or `UTF-16` [byte order mark](https://en.wikipedia.org/wiki/Byte_order_mark), or if the h (handle) flag is used. If omitted, the current value of `A_FileEncoding` is used.


### Return value

Returns the number of bytes that were written.
