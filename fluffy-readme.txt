------------- Instructions for compiling 2025 -------------

- Some libraries were found as they were already installed by vcpkg, but FLTK had to be added
-- vcpkg install fltk

- Find this line in CMakeLists.txt:
	 string(REGEX REPLACE "/Zi|/ZI" "/Z7" _value ${${_var}})
- Replace with these two lines (in order to add bigobj compile argument):
	#string(REGEX REPLACE "/Zi|/ZI" "/Z7" _value ${${_var}})
	string(REGEX REPLACE "/Z7|/Zi|/ZI" "/Z7 /bigobj" _value ${${_var}})

- Find this line in CMakeLists.txt
	${SDL_DLL} "$<TARGET_FILE_DIR:${JA2_BINARY}>")
- Replace with these two lines:
	#${SDL_DLL} "$<TARGET_FILE_DIR:${JA2_BINARY}>")
	"C:\\apps\\vcpkg\\packages\\sdl2_x64-windows\\bin\\SDL2.dll" "$<TARGET_FILE_DIR:${JA2_BINARY}>")

- In Visual Studio->Project->CMake Settings->CMake Variables->LOCAL_FLTK_LIB = TRUE

- Remotes:
-- ja2-ub-comparison: https://github.com/Manuel-K/ja2-ub-comparison
-- main-repo: https://github.com/ja2-stracciatella/ja2-stracciatella

------------- Below are old instructions I used 2021 or 2022 -------------
I did this in order to setting this up to to compile in VS2019:

- Edited CMakeLists.txt like so:
-- Replace:
		${SDL_DLL} "$<TARGET_FILE_DIR:${JA2_BINARY}>")
-- With:
		# ${SDL_DLL} "$<TARGET_FILE_DIR:${JA2_BINARY}>")
		H:/apps/code/libcurl/vcpkg/packages/sdl2_x64-windows/bin/sdl2.dll "$<TARGET_FILE_DIR:${JA2_BINARY}>") #Fluffy: Hardcoded path for SDL2.dll

- Open project folder in VS2019
- View -> Terminal
-- Do these commands:
		mkdir _bin
		cd _bin
		cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/toolchain-msvc.cmake ..

- This will fail due to not finding SDL2. Fix this by opening _bin/CMakeCache.txt and doing these changes.
-- Replace:

		//Path to a library.
		SDL2MAIN_LIBRARY:FILEPATH=SDL2MAIN_LIBRARY-NOTFOUND

		//Path to a file.
		SDL2_INCLUDE_DIR:PATH=SDL2_INCLUDE_DIR-NOTFOUND

		//Path to a library.
		SDL2_LIBRARY_TEMP:FILEPATH=SDL2_LIBRARY_TEMP-NOTFOUND

-- With:

		//Path to a library.
		SDL2MAIN_LIBRARY:FILEPATH=H:/apps/code/libcurl/vcpkg/installed/x64-windows/lib/manual-link/SDL2main.lib

		//Path to a file.
		SDL2_INCLUDE_DIR:PATH=H:/apps/code/libcurl/vcpkg/installed/x64-windows/include/SDL2

		//Where the SDL2 Library can be found
		SDL2_LIBRARY:STRING=H:/apps/code/libcurl/vcpkg/installed/x64-windows/lib/manual-link/SDL2main.lib;H:/apps/code/libcurl/vcpkg/installed/x64-windows/lib/SDL2.lib

		//Path to a file.
		SDL2_RUNTIME_LIBRARY:FILEPATH=H:/apps/code/libcurl/vcpkg/installed/x64-windows/bin/SDL2.dll

		//Path to a library.
		SDL2_SDLMAIN_LIBRARY:FILEPATH=H:/apps/code/libcurl/vcpkg/installed/x64-windows/lib/manual-link/SDL2main.lib

- Then repeat the cmake command in the terminal

- And everything is now done. Open _bin/ja2.vcxproj in Visual Studio to start working.
