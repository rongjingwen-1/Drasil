/** \file OutputFormat.hpp
    \author Thulasi Jegatheesan
    \brief Provides the function for writing outputs
*/
#ifndef OutputFormat_h
#define OutputFormat_h

#include <string>

using std::ofstream;
using std::string;

/** \brief Writes the output values to output.txt
    \param T_W temperature of the water: the average kinetic energy of the particles within the water (degreeC)
    \param E_W change in heat energy in the water: change in thermal energy within the water (J)
*/
void write_output(double T_W, double E_W);

#endif
