from __future__ import print_function
import sys
import math

def func_read_table(filename, z_vector, x_matrix, y_matrix):
    outfile = open("log.txt", "a")
    print("function func_read_table called with inputs: {", file=outfile)
    print("  filename = ", end='', file=outfile)
    print(filename, end='', file=outfile)
    print(", ", file=outfile)
    print("  z_vector = ", end='', file=outfile)
    print(z_vector, end='', file=outfile)
    print(", ", file=outfile)
    print("  x_matrix = ", end='', file=outfile)
    print(x_matrix, end='', file=outfile)
    print(", ", file=outfile)
    print("  y_matrix = ", end='', file=outfile)
    print(y_matrix, file=outfile)
    print("  }", file=outfile)
    outfile.close()
    
    linetokens = []
    lines = []
    infile = open(filename, "r")
    line = infile.readline().rstrip()
    linetokens = line.split(",")
    for stringlist_i in range(0, (len(linetokens) // 1), 1):
        z_vector.append(float(linetokens[((stringlist_i * 1) + 0)]))
    outfile = open("log.txt", "a")
    print("var 'z_vector' assigned to ", end='', file=outfile)
    print(z_vector, end='', file=outfile)
    print(" in module ReadTable", file=outfile)
    outfile.close()
    lines = infile.readlines()
    for i in range(0, len(lines), 1):
        linetokens = lines[i].split(",")
        x_matrix_temp = []
        y_matrix_temp = []
        for stringlist_i in range(0, (len(linetokens) // 2), 1):
            x_matrix_temp.append(float(linetokens[((stringlist_i * 2) + 0)]))
            y_matrix_temp.append(float(linetokens[((stringlist_i * 2) + 1)]))
        x_matrix.append(x_matrix_temp)
        y_matrix.append(y_matrix_temp)
    outfile = open("log.txt", "a")
    print("var 'x_matrix' assigned to ", end='', file=outfile)
    print(x_matrix, end='', file=outfile)
    print(" in module ReadTable", file=outfile)
    outfile.close()
    outfile = open("log.txt", "a")
    print("var 'y_matrix' assigned to ", end='', file=outfile)
    print(y_matrix, end='', file=outfile)
    print(" in module ReadTable", file=outfile)
    outfile.close()
    infile.close()


