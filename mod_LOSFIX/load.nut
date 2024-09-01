::include("mod_LOSFIX/msu_settings");	// This file needs priority

::includeFiles(::IO.enumerateFiles("mod_LOSFIX/hooks"));		// This will load and execute all hooks
