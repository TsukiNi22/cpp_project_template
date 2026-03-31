"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

 ██╗  ██╗ █████╗ ██████╗ ████████╗ █████╗ ███╗   ██╗██╗ █████╗ 
 ╚██╗██╔╝██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗████╗  ██║██║██╔══██╗
  ╚███╔╝ ███████║██████╔╝   ██║   ███████║██╔██╗ ██║██║███████║
  ██╔██╗ ██╔══██║██╔══██╗   ██║   ██╔══██║██║╚██╗██║██║██╔══██║
 ██╔╝ ██╗██║  ██║██║  ██║   ██║   ██║  ██║██║ ╚████║██║██║  ██║
 ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝

Edition:
##  04/03/2026 by Tsukini

File Name:
##  const.py

File Description:
##  Different const used in python scripts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

##### Const #####
class Return:
    """
        Return values
    """
    OK = 0 # Return value upon success on a call function
    KO = 1 # Return value upon fail on a call function

class Error:
    """
        Error values
    """
    FATAL   = 0b1000    # Global error, the program whole execution won't be able to run after this        (100% execution stop)
    LOCAL   = 0b100     # Local error, the program local execution won't probably be able to run after this (some chance of execution stop)
    ACTION  = 0b10      # Same~~ as Return.KO, a program action execution won't be able to run after this   (low chance of execution stop)

class Value:
    """
        Different values wihtout a precise category
    """
    # Default values
    EXCEPTION_TYPE = {
        "None":    0b0001, # Forced to exist
        "Fatal":   0b0010,
        "Error":   0b0100,
        "Warning": 0b1000,
    }

class File:
    """
        Different files path
    """
    REQUIREMENTS = "cmake/script/requirements.txt"
    CONFIG_EXCEPTION = "cmake/config/exception/"
    EXCEPTION_DEFINE_HEADER = "include/utils/exception/ExceptionDefine.hpp"
    GENERATED_EXCEPTION_HEADER = "include/utils/exception/generated_exception_header.hpp"

class Name:
    """
        Different names
    """
    EXCEPTION_CODE_ENUM = "Code"
    EXCEPTION_MESSAGE_VAR = "Message"
