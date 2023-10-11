# This is an analytical time domain scattering matrix simulator
# Outputting a cumulative solution for each port in a series of connected scattering junctions.
import copy
import numpy as np


def runSimulation(junctionMatrix: list[list[list[int]]], cumulativeMatrix, simulationLength):
    currentJunctionMatrix = junctionMatrix
    i = 0
    while i < simulationLength:
        newJunctionMatrix = scatterSignals(currentJunctionMatrix)
        currentJunctionMatrix = connections(newJunctionMatrix, cumulativeMatrix)
        i+=1
    print(cumulativeMatrix)
    return currentJunctionMatrix


def scatterSignals(junctionMatrix):
    scatteringMatrix = np.matrix([
    [0.5,-0.5,-0.5,-0.5],
    [-0.5,0.5,-0.5,-0.5],
    [-0.5,-0.5,0.5,-0.5],
    [-0.5,-0.5,-0.5,0.5]])
    for i in range(len(junctionMatrix)):
        for j in range(len(junctionMatrix[i])):
            junctionMatrix[i][j] = np.dot(junctionMatrix[i][j], scatteringMatrix)
    return junctionMatrix

def connections(junctionMatrix, cumulativeMatrix):
    newJunctionMatrix = copy.deepcopy(junctionMatrix)
    for i in range(len(junctionMatrix)):
        for j in range(len(junctionMatrix[i])):
            for port in range(len(np.array(junctionMatrix[i][j])[0])):
                if(junctionMatrix[i][j][0, port] == 0.0):
                    continue
                if(port == 0):
                    makeConnection(junctionMatrix, newJunctionMatrix, cumulativeMatrix, i, j-1, i, j, port, 2)
                if(port == 1):
                    makeConnection(junctionMatrix, newJunctionMatrix, cumulativeMatrix, i-1, j, i, j, port, 3)
                if(port == 2):
                    makeConnection(junctionMatrix, newJunctionMatrix, cumulativeMatrix, i, j+1, i, j, port, 0)
                if(port == 3):
                    makeConnection(junctionMatrix, newJunctionMatrix, cumulativeMatrix, i+1, j, i, j, port, 1)
    return newJunctionMatrix

def makeConnection(junctionMatrix, newJunctionMatrix, cumulativeMatrix, i2, j2, i1, j1, port, inPort):
    # non-reflective grid boundaries.
    # cummulative pulses at each port recorded in the cumulativeMatrix.
    rows = len(junctionMatrix)
    cols = len(junctionMatrix[0])
    if(i2 < 0):
        cumulativeMatrix[i1][j1][1] += newJunctionMatrix[i1][j1][0,1]
        newJunctionMatrix[i1][j1][0,1] = 0
    elif(i2 >= rows):
        cumulativeMatrix[i1][j1][3] += newJunctionMatrix[i1][j1][0,3]
        newJunctionMatrix[i1][j1][0,3] = 0
    elif(j2 < 0):
        cumulativeMatrix[i1][j1][0] += newJunctionMatrix[i1][j1][0,0]
        newJunctionMatrix[i1][j1][0,0] = 0
    elif (j2 >= cols):
        cumulativeMatrix[i1][j1][2] += newJunctionMatrix[i1][j1][0,2]
        newJunctionMatrix[i1][j1][0,2] = 0
    else:
        newJunctionMatrix[i2][j2][0,inPort] = junctionMatrix[i1][j1][0,port]
        newJunctionMatrix[i1][j1][0, port] = 0
    return

#shape of junctions being considered, all four port junctions in rows and columns.
junctionMatrix = [[[1,0,0,0],[0,0,0,0],[0,0,0,0]],
                  [[0,0,0,0],[0,0,0,0],[0,0,0,0]],
                  [[1,0,0,0],[0,0,0,0],[0,0,0,0]]]

cumulativeMatrix = [[[0,0,0,0],[0,0,0,0],[0,0,0,0]],
                    [[0,0,0,0],[0,0,0,0],[0,0,0,0]],
                    [[0,0,0,0],[0,0,0,0],[0,0,0,0]]]

# Output after 7 iterations
[[[0.6875, -0.3125, 0, 0], [0, 0.3125, 0, 0], [0, -0.3125, -0.3125, 0]], 
 [[0.3125, 0, 0, 0],       [0, 0, 0, 0],      [0, 0, 0.3125, 0]], 
 [[0.6875, 0, 0, -0.3125], [0, 0, 0, 0.3125], [0, 0, -0.3125, -0.3125]]]


runSimulation(junctionMatrix, cumulativeMatrix, 7)
