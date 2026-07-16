/**************************************************************\

 ██╗  ██╗ █████╗ ██████╗ ████████╗ █████╗ ███╗   ██╗██╗ █████╗ 
 ╚██╗██╔╝██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗████╗  ██║██║██╔══██╗
  ╚███╔╝ ███████║██████╔╝   ██║   ███████║██╔██╗ ██║██║███████║
  ██╔██╗ ██╔══██║██╔══██╗   ██║   ██╔══██║██║╚██╗██║██║██╔══██║
 ██╔╝ ██╗██║  ██║██║  ██║   ██║   ██║  ██║██║ ╚████║██║██║  ██║
 ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝

Edition:
##  @date 16/07/2026 by @author Tsukini

File Name:
##  @file Core-init.cpp

File Description:
##  You know, I don t think there are good or bad descriptions,
##  for me, life is all about functions...
\**************************************************************/

#define _Verbose
#define _Arguments
#include "utils/utils.hpp"
#include "template/Core.hpp"
#include <optional>
#include <string>

static nodiscard std::optional<std::string> StatusParsingHook(const std::string& option)
{
    try {
        if (option.empty())
            throw std::invalid_argument("empty");
        if (option == "enable" || option == "disable") return std::nullopt;
        else return "Invalid status option (enable|disable): " + option;
    } catch (const std::exception& e) {
        return std::string(e.what()) + ": " + option;
    }
}

static nodiscard std::optional<std::string> VerboseParsingHook(const std::string& option)
{
    if (option == "none" || option == "basic" || option == "advanced" || option == "debug") return std::nullopt;
    return "Invalid verbose level, should be (none|basic|advanced|debug), but got: " + option;
}

void template::Core::init(int argc, const char *const argv[])
{
    utils::arguments::ArgParser parser = utils::arguments::ArgParser("template", "...");

    // Setup the usages
    parser.setUsage("template",
        "default",
        false,
        {
            {"verbose", false},
        },
        "Default usage"
    );
    parser.setUsage("template-small",
        "minimal",
        false,
        {
        },
        "Minimal usage"
    );

    // Setup the flags
    parser.setFlag("verbose",
        {"v", "", "verbose"},
        {
            {"level", true, VerboseParsingHook}
        },
        "Set the verbose level none|basic|advanced|debug (default: basic)"
    );

    // Extract settings
    utils::arguments::ParsedUsages usages = parser.parse(argc, argv);
    for (const auto& [id, _, options]: usages.front().arguments) {
        const std::string& value = (options.empty() ? "" : options.front());
        if (id == "verbose") {
            if      (value == "none")     set_verbose(zappy::Verbose::None)
            else if (value == "basic")    set_verbose(zappy::Verbose::Basic)
            else if (value == "advanced") set_verbose(zappy::Verbose::Advanced)
            else if (value == "debug")    set_verbose(zappy::Verbose::Debug)
        }
    }

    onBasicVerbose("Core setup!");
}
