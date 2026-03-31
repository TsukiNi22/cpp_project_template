/**************************************************************\
Edition:
##  @date 05/03/2026 by @author Tsukini

File Name:
##  @file ExceptionDefine.hpp

File Description:
##  Definition of the error code&message
\**************************************************************/

#ifndef EXCEPTIONDEFINE_H
    #define EXCEPTIONDEFINE_H

    //----------------------------------------------------------------//
    /* INCLUDE */

    /* type */
    #include "generated_exception_header.hpp"   // utils::exception::Code, utils::exception::Message, utils::exception::Info, utils::exception::Restriction
    #include <cstdint>                          // std::uint8_t

    //----------------------------------------------------------------//
    /* DEFINE */
    
    /* Definition of the different return status */
    #ifndef OK
        #define OK 0 // Valid
    #endif
    #ifndef KO
        #define KO -1 // Error
    #endif

namespace utils::exception { // namespace start
//----------------------------------------------------------------//
/* TYPEDEF */

/* Definition of the different exception type */
enum Type: std::uint8_t {
    None    = 0b0001, // Exception like Exit, does nothing (ignore other type)
    Fatal   = 0b0010,
    Error   = 0b0100,
    Warning = 0b1000,
};

// ------------ Operator ---------- //
constexpr inline utils::exception::Type operator|(utils::exception::Type ltype, utils::exception::Type rtype)
{
    return static_cast<utils::exception::Type>(static_cast<std::uint8_t>(ltype) | static_cast<std::uint8_t>(rtype));
}

constexpr inline utils::exception::Type& operator|=(utils::exception::Type& ltype, utils::exception::Type rtype)
{
    ltype = ltype | rtype;
    return ltype;
}

constexpr inline utils::exception::Type operator&(utils::exception::Type ltype, utils::exception::Type rtype)
{
    return static_cast<utils::exception::Type>(static_cast<std::uint8_t>(ltype) & static_cast<std::uint8_t>(rtype));
}

constexpr inline utils::exception::Type& operator&=(utils::exception::Type& ltype, utils::exception::Type rtype)
{
    ltype = ltype & rtype;
    return ltype;
}

} // namespace end
#endif /* EXCEPTIONDEFINE_H */
