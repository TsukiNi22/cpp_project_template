/**************************************************************\

 ██╗  ██╗ █████╗ ██████╗ ████████╗ █████╗ ███╗   ██╗██╗ █████╗
 ╚██╗██╔╝██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗████╗  ██║██║██╔══██╗
  ╚███╔╝ ███████║██████╔╝   ██║   ███████║██╔██╗ ██║██║███████║
  ██╔██╗ ██╔══██║██╔══██╗   ██║   ██╔══██║██║╚██╗██║██║██╔══██║
 ██╔╝ ██╗██║  ██║██║  ██║   ██║   ██║  ██║██║ ╚████║██║██║  ██║
 ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝

Edition:
##  @date 17/10/2026 by @author Tsukini

File Name:
##  @file Core.cpp

File Description:
##  Unit tests of the Core class (init from the arguments, run)
\**************************************************************/

#define _Exception
#define _Verbose
#include <utils/utils.hpp>
#include "template/Core.hpp"
#include <gtest/gtest.h>

/* Init */
TEST(Core, InitWithoutArgument)
{
    template::Core core;
    const char* const argv[] = {"template", nullptr};

    EXPECT_NO_THROW(core.init(1, argv));
}

TEST(Core, InitSetsTheVerboseLevel)
{
    template::Core core;
    const char* const argv[] = {"template", "--verbose", "none", nullptr};

    EXPECT_NO_THROW(core.init(3, argv));
    EXPECT_EQ(utils::verbose::verbose.load(), utils::verbose::Verbose::None);
}

TEST(Core, InitRefusesAnInvalidVerboseLevel)
{
    template::Core core;
    const char* const argv[] = {"template", "--verbose", "loud", nullptr};

    EXPECT_THROW(core.init(3, argv), utils::exception::IException);
}

/* Run */
TEST(Core, RunDoesNothing)
{
    template::Core core;

    EXPECT_NO_THROW(core.run());
}
