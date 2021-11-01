#include "Logger.h"
#include "MemMan.h"
#include "SGPStrings.h"
#include "Types.h"

#include <string_theory/string>

#include <stdio.h>
#if defined(_MSC_VER)
#define vsnprintf(buf, size, format, args) vsnprintf_s(buf, size, _TRUNCATE, format, args)
#endif

void LogMessage(bool isAssert, LogLevel level, const char* file, const ST::string& str)
{
	Logger_log(level, str.c_str(), file);

	#ifdef ENABLE_ASSERTS
	if (isAssert)
	{
		abort();
	}
	#endif
}

void LogMessage(bool isAssert, LogLevel level, const char *file, const char *format, ...)
{
	//Fluffy (Misc): Changed this code to allow for messages longer than 256 characters
	int bufferSize = 256, formattedLength = -1;
	char *message = 0;
	va_list args;
	for(int i = 0; i < 10; i++)
	{
		if(i > 0) //If previous attempt failed then increase buffer size
		{
			MemFree(message);
			if(formattedLength != -1)
				bufferSize = formattedLength + 1;
			else
				bufferSize *= 2;
		}
		message = (char *) MemAlloc(bufferSize);
		va_start(args, format);
		formattedLength = vsnprintf(message, bufferSize, format, args);
		va_end(args);
		if(formattedLength < bufferSize && formattedLength != -1)
			break;
	}

	ST::string err_msg;
	ST::string str = st_checked_buffer_to_string(err_msg, ST::char_buffer(message, strlen(message)));
	MemFree(message);
	if (!err_msg.empty())
	{
		STLOGW("LogMessage: {}", err_msg);
	}
	LogMessage(isAssert, level, file, str);
}
