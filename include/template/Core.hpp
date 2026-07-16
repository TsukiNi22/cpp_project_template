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
##  @file Core.hpp

File Description:
##  You know, I don t think there are good or bad descriptions,
##  for me, life is all about functions...
\**************************************************************/

#ifndef CORE_H
    #define CORE_H

    //----------------------------------------------------------------//
    /* INCLUDE */

    /* type */
    //#include <iostream>

namespace template { // namespace start
//----------------------------------------------------------------//
/* CLASS */

class Core {
    private:
        /* Nothing */

    public:
        // ---------- Pre-Function -------- //
        void init(int argc, const char* argv[]);
        void run(void);

        // ------------ Function ---------- //

        // ------------ Operator ---------- //
        Core& operator=(const Core& other) = delete;
        Core& operator=(Core&& other) = delete;

        // ---------- Constructor --------- //
        Core() = default;
        Core(const Core& other) = delete;
        Core(Core&& other) = delete;

        // ----------- Destructor --------- //
        ~Core() = default;
};

} // namespace end
#endif /* CORE_H */
