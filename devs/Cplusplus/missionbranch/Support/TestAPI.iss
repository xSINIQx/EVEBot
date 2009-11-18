/*
	TestAPI

	Copies (usually minimal) of EVEBot objects required to do standalone testing of various evebot objects

	-- CyberTech
*/

#define TESTAPI_DEBUG 0
#include ../core/defines.iss

objectdef obj_UI
{
	variable string SVN_REVISION = "$Rev$"
	variable int Version
	variable string LogFile

	method Initialize()
	{
		This.LogFile:Set["./config/logs/TestAPI_${Script.Filename}.log"]

		redirect -append "${This.LogFile}" echo "--------------------------------------------------------------------------------------"
		redirect -append "${This.LogFile}" echo "** ${Script.Filename} starting on ${Time.Date} at ${Time.Time24}"
	}

	method UpdateConsole(string StatusMessage, int Level=LOG_STANDARD, int Indent=0)
	{
		/*
			Level = LOG_MINOR - Minor - Log, do not print to screen.
			Level = LOG_STANDARD - Standard, Log and Print to Screen
			Level = LOG_CRITICAL - Critical, Log, Log to Critical Log, and print to screen
		*/
		variable string msg
		variable int Count

		if ${StatusMessage(exists)}
		{
			if ${Level} == LOG_DEBUG && TESTAPI_DEBUG == 0
			{
				return
			}

			msg:Set["${Time.Time24}: "]

			for (Count:Set[1]; ${Count}<=${Indent}; Count:Inc)
			{
  				msg:Concat[" "]
  			}
  			msg:Concat["${StatusMessage}"]

			if ${Level} > LOG_MINOR
			{
				echo ${msg}
			}

			redirect -append "${This.LogFile}" Echo "${msg}"
		}
	}

}
