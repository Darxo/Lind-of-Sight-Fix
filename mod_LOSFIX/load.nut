::include("mod_LOSFIX/some_priority_script");	// This file needs priority

::includeFiles(::IO.enumerateFiles("mod_LOSFIX/hooks"));		// This will load and execute all hooks
