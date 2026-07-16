/**************************************************************\
Edition:
##  @date 16/07/2026 by @author Tsukini

File Name:
##  @file main.cpp

File Description:
##  You know, I don t think there are good or bad descriptions,
##  for me, life is all about functions...
\**************************************************************/

#define _Exception
#define _Attribute
#include "utils/utils.hpp"
#include <exception>
#include <iostream>

cold nodiscard int main(int argc, const char* argv[])
{
    // Init core class ...
    template::Core core;

    try {
        // Call to the main endpoint
        core.init(argc, argv);
        core.run();
    } catch (const utils::exception::IException& e) { // Custom error
        std::cout << e.formated() << std::endl;
        return KO;
    }
    return OK;
}
