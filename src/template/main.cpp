/**************************************************************\
Edition:
##  @date 25/07/2026 by @author Tsukini

File Name:
##  @file main.cpp

File Description:
##  You know, I don t think there are good or bad descriptions,
##  for me, life is all about functions...
\**************************************************************/

#define _Exception
#define _Attribute
#include "utils/utils.hpp"
#include "template/Core.hpp"
#include <exception>
#include <iostream>

_cold _nodiscard int main(int argc, const char* argv[])
{
    // Init core class ...
    template::Core core;

    try {
        // Call to the main endpoint
        core.init(argc, argv);
        core.run();
    } catch (const utils::exception::IException& e) { // Custom error
        if (e.isNone() && e.getCode() == utils::exception::Code::Exit) return OK; // Exit - no error
        std::cerr << e.formated() << std::endl;
        return KO;
    }
    return OK;
}
