"""
Pure Python implementations of functions in fatiando.gravmag.tesseroid.
Used instead of Cython versions if those are not available.
"""
import numpy
from libc.math cimport sin, cos, sqrt
from fatiando.constants import MEAN_EARTH_RADIUS
# Import Cython definitions for numpy
cimport numpy
cimport cython

cdef:
    double d2r = numpy.pi/180.
    double[::1] nodes
nodes = numpy.array([-0.577350269, 0.577350269])

@cython.boundscheck(False)
@cython.wraparound(False)
def too_close(numpy.ndarray[long, ndim=1] points,
        numpy.ndarray[double, ndim=1] distance, double value):
    cdef:
        int i, j, l, size = len(points)
        numpy.ndarray[long, ndim=1] buff
    buff = numpy.empty(size, dtype=numpy.int)
    i = 0
    j = size - 1
    for l in range(size):
        if distance[l] > 0 and distance[l] < value:
            buff[i] = points[l]
            i += 1
        else:
            buff[j] = points[l]
            j -= 1
    return buff[:i], buff[j + 1:size]

@cython.boundscheck(False)
@cython.wraparound(False)
def distance(tesseroid,
    numpy.ndarray[double, ndim=1] lon,
    numpy.ndarray[double, ndim=1] sinlat,
    numpy.ndarray[double, ndim=1] coslat,
    numpy.ndarray[double, ndim=1] radius,
    numpy.ndarray[long, ndim=1] points,
    numpy.ndarray[double, ndim=1] buff):
    cdef:
        unsigned int i, l, size = len(points)
        double tes_radius, tes_lat, tes_lon
        double w, e, s, n, top, bottom
    w, e, s, n, top, bottom = tesseroid
    tes_radius = top + MEAN_EARTH_RADIUS
    tes_lat = d2r*0.5*(s + n)
    tes_lon = d2r*0.5*(w + e)
    for l in range(size):
        i = points[l]
        buff[l] = sqrt(radius[i]**2 + tes_radius**2 -
            2.*radius[i]*tes_radius*(sinlat[i]*sin(tes_lat) +
                coslat[i]*cos(tes_lat)*cos(lon[i] - tes_lon)))

@cython.boundscheck(False)
@cython.wraparound(False)
cdef inline double _scale_nodes(tesseroid,
        numpy.ndarray[double, ndim=1] lonc,
        numpy.ndarray[double, ndim=1] sinlatc,
        numpy.ndarray[double, ndim=1] coslatc,
        numpy.ndarray[double, ndim=1] rc):
    cdef:
        double dlon, dlat, dr, mlon, mlat, mr, scale, latc
        unsigned int i
        double w, e, s, n, top, bottom
    w, e, s, n, top, bottom = tesseroid
    dlon = e - w
    dlat = n - s
    dr = top - bottom
    mlon = 0.5*(e + w)
    mlat = 0.5*(n + s)
    mr = 0.5*(top + bottom + 2.*MEAN_EARTH_RADIUS)
    # Scale the GLQ nodes to the integration limits
    for i in range(2):
        lonc[i] = d2r*(0.5*dlon*nodes[i] + mlon)
        latc = d2r*(0.5*dlat*nodes[i] + mlat)
        sinlatc[i] = sin(latc)
        coslatc[i] = cos(latc)
        rc[i] = (0.5*dr*nodes[i] + mr)
    scale = d2r*dlon*d2r*dlat*dr*0.125
    return scale

#def potential(tesseroid,
    #numpy.ndarray[double, ndim=1] lons,
    #numpy.ndarray[double, ndim=1] lats,
    #numpy.ndarray[double, ndim=1] radii,
    #numpy.ndarray[double, ndim=1] nodes,
    #numpy.ndarray[double, ndim=1] weights):
    #"""
    #Integrate potential using the Gauss-Legendre Quadrature
    #"""
    #cdef unsigned int order = len(nodes), ndata = len(lons), i, j, k, l
    #cdef numpy.ndarray[double, ndim=1] lonc, latc, rc, sinlatc, coslatc
    #cdef numpy.ndarray[double, ndim=1] result
    #cdef double scale, kappa, sinlat, coslat, radii_sqr, coslon, l_sqr
    ## Put the nodes in the corrent range
    #lonc, latc, rc, scale = _scale_nodes(tesseroid, nodes)
    #result = numpy.zeros(ndata, numpy.float)
    ## Pre-compute sines, cossines and powers
    #sinlatc = numpy.sin(latc)
    #coslatc = numpy.cos(latc)
    ## Start the numerical integration
    #for l in range(ndata):
        #sinlat = sin(lats[l])
        #coslat = cos(lats[l])
        #radii_sqr = radii[l]**2
        #for i in range(2):
            #coslon = cos(lons[l] - lonc[i])
            #for j in range(2):
                #for k in range(2):
                    #l_sqr = (radii_sqr + rc[k]**2 -
                             #2.*radii[l]*rc[k]*(
                                #sinlat*sinlatc[j] + coslat*coslatc[j]*coslon))
                    #kappa = (rc[k]**2)*coslatc[j]
                    #result[l] = result[l] + (weights[i]*weights[j]*weights[k]*
                        #kappa/sqrt(l_sqr))
        #result[l] = result[l]*scale
    #return result

#def gx(tesseroid,
    #numpy.ndarray[double, ndim=1] lons,
    #numpy.ndarray[double, ndim=1] lats,
    #numpy.ndarray[double, ndim=1] radii,
    #numpy.ndarray[double, ndim=1] nodes,
    #numpy.ndarray[double, ndim=1] weights):
    #"""
    #Integrate gx using the Gauss-Legendre Quadrature
    #"""
    #cdef unsigned int order = len(nodes), ndata = len(lons), i, j, k, l
    #cdef numpy.ndarray[double, ndim=1] lonc, latc, rc, sinlatc, coslatc
    #cdef numpy.ndarray[double, ndim=1] result
    #cdef double scale, kappa, sinlat, coslat, radii_sqr, coslon, l_sqr
    #cdef double kphi
    ## Put the nodes in the corrent range
    #lonc, latc, rc, scale = _scale_nodes(tesseroid, nodes)
    #result = numpy.zeros(ndata, numpy.float)
    ## Pre-compute sines, cossines and powers
    #sinlatc = numpy.sin(latc)
    #coslatc = numpy.cos(latc)
    ## Start the numerical integration
    #for l in range(ndata):
        #sinlat = sin(lats[l])
        #coslat = cos(lats[l])
        #radii_sqr = radii[l]**2
        #for i in range(2):
            #coslon = cos(lons[l] - lonc[i])
            #for j in range(2):
                #kphi = coslat*sinlatc[j] - sinlat*coslatc[j]*coslon
                #for k in range(2):
                    #l_sqr = (radii_sqr + rc[k]**2 -
                             #2.*radii[l]*rc[k]*(
                                #sinlat*sinlatc[j] + coslat*coslatc[j]*coslon))
                    #kappa = (rc[k]**2)*coslatc[j]
                    #result[l] = result[l] + (weights[i]*weights[j]*weights[k]*
                        #kappa*rc[k]*kphi/(l_sqr**1.5))
        #result[l] = result[l]*scale
    #return result

#def gy(tesseroid,
    #numpy.ndarray[double, ndim=1] lons,
    #numpy.ndarray[double, ndim=1] lats,
    #numpy.ndarray[double, ndim=1] radii,
    #numpy.ndarray[double, ndim=1] nodes,
    #numpy.ndarray[double, ndim=1] weights):
    #"""
    #Integrate gy using the Gauss-Legendre Quadrature
    #"""
    #cdef unsigned int order = len(nodes), ndata = len(lons), i, j, k, l
    #cdef numpy.ndarray[double, ndim=1] lonc, latc, rc, sinlatc, coslatc
    #cdef numpy.ndarray[double, ndim=1] result
    #cdef double scale, kappa, sinlat, coslat, radii_sqr, coslon, l_sqr
    #cdef double sinlon
    ## Put the nodes in the corrent range
    #lonc, latc, rc, scale = _scale_nodes(tesseroid, nodes)
    #result = numpy.zeros(ndata, numpy.float)
    ## Pre-compute sines, cossines and powers
    #sinlatc = numpy.sin(latc)
    #coslatc = numpy.cos(latc)
    ## Start the numerical integration
    #for l in range(ndata):
        #sinlat = sin(lats[l])
        #coslat = cos(lats[l])
        #radii_sqr = radii[l]**2
        #for i in range(2):
            #coslon = cos(lons[l] - lonc[i])
            #sinlon = sin(lonc[i] - lons[l])
            #for j in range(2):
                #for k in range(2):
                    #l_sqr = (radii_sqr + rc[k]**2 -
                             #2.*radii[l]*rc[k]*(
                                #sinlat*sinlatc[j] + coslat*coslatc[j]*coslon))
                    #kappa = (rc[k]**2)*coslatc[j]
                    #result[l] = result[l] + (weights[i]*weights[j]*weights[k]*
                        #kappa*rc[k]*coslatc[j]*sinlon/(l_sqr**1.5))
        #result[l] = result[l]*scale
    #return result

#def gz(tesseroid,
    #numpy.ndarray[double, ndim=1] lons,
    #numpy.ndarray[double, ndim=1] lats,
    #numpy.ndarray[double, ndim=1] radii,
    #numpy.ndarray[double, ndim=1] nodes,
    #numpy.ndarray[double, ndim=1] weights):
    #"""
    #Integrate gz using the Gauss-Legendre Quadrature
    #"""
    #cdef unsigned int order = len(nodes), ndata = len(lons), i, j, k, l
    #cdef numpy.ndarray[double, ndim=1] lonc, latc, rc, sinlatc, coslatc
    #cdef numpy.ndarray[double, ndim=1] result
    #cdef double scale, kappa, sinlat, coslat, radii_sqr, coslon, l_sqr
    #cdef double cospsi
    ## Put the nodes in the corrent range
    #lonc, latc, rc, scale = _scale_nodes(tesseroid, nodes)
    #result = numpy.zeros(ndata, numpy.float)
    ## Pre-compute sines, cossines and powers
    #sinlatc = numpy.sin(latc)
    #coslatc = numpy.cos(latc)
    ## Start the numerical integration
    #for l in range(ndata):
        #sinlat = sin(lats[l])
        #coslat = cos(lats[l])
        #radii_sqr = radii[l]**2
        #for i in range(2):
            #coslon = cos(lons[l] - lonc[i])
            #for j in range(2):
                #cospsi = sinlat*sinlatc[j] + coslat*coslatc[j]*coslon
                #for k in range(2):
                    #l_sqr = (radii_sqr + rc[k]**2 -
                             #2.*radii[l]*rc[k]*(
                                #sinlat*sinlatc[j] + coslat*coslatc[j]*coslon))
                    #kappa = (rc[k]**2)*coslatc[j]
                    #result[l] = result[l] + (weights[i]*weights[j]*weights[k]*
                        #kappa*(rc[k]*cospsi - radii[l])/(l_sqr**1.5))
        #result[l] = result[l]*scale
    #return result

#def gxx(tesseroid,
    #numpy.ndarray[double, ndim=1] lons,
    #numpy.ndarray[double, ndim=1] lats,
    #numpy.ndarray[double, ndim=1] radii,
    #numpy.ndarray[double, ndim=1] nodes,
    #numpy.ndarray[double, ndim=1] weights):
    #"""
    #Integrate gxx using the Gauss-Legendre Quadrature
    #"""
    #cdef unsigned int order = len(nodes), ndata = len(lons), i, j, k, l
    #cdef numpy.ndarray[double, ndim=1] lonc, latc, rc, sinlatc, coslatc
    #cdef numpy.ndarray[double, ndim=1] result
    #cdef double scale, kappa, sinlat, coslat, radii_sqr, coslon, l_sqr
    #cdef double kphi
    ## Put the nodes in the corrent range
    #lonc, latc, rc, scale = _scale_nodes(tesseroid, nodes)
    #result = numpy.zeros(ndata, numpy.float)
    ## Pre-compute sines, cossines and powers
    #sinlatc = numpy.sin(latc)
    #coslatc = numpy.cos(latc)
    ## Start the numerical integration
    #for l in range(ndata):
        #sinlat = sin(lats[l])
        #coslat = cos(lats[l])
        #radii_sqr = radii[l]**2
        #for i in range(2):
            #coslon = cos(lons[l] - lonc[i])
            #for j in range(2):
                #kphi = coslat*sinlatc[j] - sinlat*coslatc[j]*coslon
                #for k in range(2):
                    #l_sqr = (radii_sqr + rc[k]**2 -
                             #2.*radii[l]*rc[k]*(
                                #sinlat*sinlatc[j] + coslat*coslatc[j]*coslon))
                    #kappa = (rc[k]**2)*coslatc[j]
                    #result[l] = result[l] + (weights[i]*weights[j]*weights[k]*
                        #kappa*(3.*((rc[k]*kphi)**2) - l_sqr)/(l_sqr**2.5))
        #result[l] = result[l]*scale
    #return result

#def gxy(tesseroid,
    #numpy.ndarray[double, ndim=1] lons,
    #numpy.ndarray[double, ndim=1] lats,
    #numpy.ndarray[double, ndim=1] radii,
    #numpy.ndarray[double, ndim=1] nodes,
    #numpy.ndarray[double, ndim=1] weights):
    #"""
    #Integrate gxy using the Gauss-Legendre Quadrature
    #"""
    #cdef unsigned int order = len(nodes), ndata = len(lons), i, j, k, l
    #cdef numpy.ndarray[double, ndim=1] lonc, latc, rc, sinlatc, coslatc
    #cdef numpy.ndarray[double, ndim=1] result
    #cdef double scale, kappa, sinlat, coslat, radii_sqr, coslon, l_sqr
    #cdef double kphi, sinlon
    ## Put the nodes in the corrent range
    #lonc, latc, rc, scale = _scale_nodes(tesseroid, nodes)
    #result = numpy.zeros(ndata, numpy.float)
    ## Pre-compute sines, cossines and powers
    #sinlatc = numpy.sin(latc)
    #coslatc = numpy.cos(latc)
    ## Start the numerical integration
    #for l in range(ndata):
        #sinlat = sin(lats[l])
        #coslat = cos(lats[l])
        #radii_sqr = radii[l]**2
        #for i in range(2):
            #coslon = cos(lons[l] - lonc[i])
            #sinlon = sin(lonc[i] - lons[l])
            #for j in range(2):
                #kphi = coslat*sinlatc[j] - sinlat*coslatc[j]*coslon
                #for k in range(2):
                    #l_sqr = (radii_sqr + rc[k]**2 -
                             #2.*radii[l]*rc[k]*(
                                #sinlat*sinlatc[j] + coslat*coslatc[j]*coslon))
                    #kappa = (rc[k]**2)*coslatc[j]
                    #result[l] = result[l] + (weights[i]*weights[j]*weights[k]*
                        #kappa*3.*(rc[k]**2)*kphi*coslatc[j]*sinlon/(l_sqr**2.5))
        #result[l] = result[l]*scale
    #return result

#def gxz(tesseroid,
    #numpy.ndarray[double, ndim=1] lons,
    #numpy.ndarray[double, ndim=1] lats,
    #numpy.ndarray[double, ndim=1] radii,
    #numpy.ndarray[double, ndim=1] nodes,
    #numpy.ndarray[double, ndim=1] weights):
    #"""
    #Integrate gxz using the Gauss-Legendre Quadrature
    #"""
    #cdef unsigned int order = len(nodes), ndata = len(lons), i, j, k, l
    #cdef numpy.ndarray[double, ndim=1] lonc, latc, rc, sinlatc, coslatc
    #cdef numpy.ndarray[double, ndim=1] result
    #cdef double scale, kappa, sinlat, coslat, radii_sqr, coslon, l_sqr
    #cdef double kphi, cospsi
    ## Put the nodes in the corrent range
    #lonc, latc, rc, scale = _scale_nodes(tesseroid, nodes)
    #result = numpy.zeros(ndata, numpy.float)
    ## Pre-compute sines, cossines and powers
    #sinlatc = numpy.sin(latc)
    #coslatc = numpy.cos(latc)
    ## Start the numerical integration
    #for l in range(ndata):
        #sinlat = sin(lats[l])
        #coslat = cos(lats[l])
        #radii_sqr = radii[l]**2
        #for i in range(2):
            #coslon = cos(lons[l] - lonc[i])
            #for j in range(2):
                #kphi = coslat*sinlatc[j] - sinlat*coslatc[j]*coslon
                #cospsi = sinlat*sinlatc[j] + coslat*coslatc[j]*coslon
                #for k in range(2):
                    #l_sqr = (radii_sqr + rc[k]**2 -
                             #2.*radii[l]*rc[k]*(
                                #sinlat*sinlatc[j] + coslat*coslatc[j]*coslon))
                    #kappa = (rc[k]**2)*coslatc[j]
                    #result[l] = result[l] + (weights[i]*weights[j]*weights[k]*
                        #kappa*3.*rc[k]*kphi*(rc[k]*cospsi - radii[l])/
                        #(l_sqr**2.5))
        #result[l] = result[l]*scale
    #return result

#def gyy(tesseroid,
    #numpy.ndarray[double, ndim=1] lons,
    #numpy.ndarray[double, ndim=1] lats,
    #numpy.ndarray[double, ndim=1] radii,
    #numpy.ndarray[double, ndim=1] nodes,
    #numpy.ndarray[double, ndim=1] weights):
    #"""
    #Integrate gyy using the Gauss-Legendre Quadrature
    #"""
    #cdef unsigned int order = len(nodes), ndata = len(lons), i, j, k, l
    #cdef numpy.ndarray[double, ndim=1] lonc, latc, rc, sinlatc, coslatc
    #cdef numpy.ndarray[double, ndim=1] result
    #cdef double scale, kappa, sinlat, coslat, radii_sqr, coslon, l_sqr
    #cdef double sinlon, deltay
    ## Put the nodes in the corrent range
    #lonc, latc, rc, scale = _scale_nodes(tesseroid, nodes)
    #result = numpy.zeros(ndata, numpy.float)
    ## Pre-compute sines, cossines and powers
    #sinlatc = numpy.sin(latc)
    #coslatc = numpy.cos(latc)
    ## Start the numerical integration
    #for l in range(ndata):
        #sinlat = sin(lats[l])
        #coslat = cos(lats[l])
        #radii_sqr = radii[l]**2
        #for i in range(2):
            #coslon = cos(lons[l] - lonc[i])
            #sinlon = sin(lonc[i] - lons[l])
            #for j in range(2):
                #for k in range(2):
                    #l_sqr = (radii_sqr + rc[k]**2 -
                             #2.*radii[l]*rc[k]*(
                                #sinlat*sinlatc[j] + coslat*coslatc[j]*coslon))
                    #kappa = (rc[k]**2)*coslatc[j]
                    #deltay = rc[k]*coslatc[j]*sinlon
                    #result[l] = result[l] + (weights[i]*weights[j]*weights[k]*
                        #kappa*(3.*(deltay**2) - l_sqr)/(l_sqr**2.5))
        #result[l] = result[l]*scale
    #return result

#def gyz(tesseroid,
    #numpy.ndarray[double, ndim=1] lons,
    #numpy.ndarray[double, ndim=1] lats,
    #numpy.ndarray[double, ndim=1] radii,
    #numpy.ndarray[double, ndim=1] nodes,
    #numpy.ndarray[double, ndim=1] weights):
    #"""
    #Integrate gyz using the Gauss-Legendre Quadrature
    #"""
    #cdef unsigned int order = len(nodes), ndata = len(lons), i, j, k, l
    #cdef numpy.ndarray[double, ndim=1] lonc, latc, rc, sinlatc, coslatc
    #cdef numpy.ndarray[double, ndim=1] result
    #cdef double scale, kappa, sinlat, coslat, radii_sqr, coslon, l_sqr
    #cdef double sinlon, deltay, deltaz, cospsi
    ## Put the nodes in the corrent range
    #lonc, latc, rc, scale = _scale_nodes(tesseroid, nodes)
    #result = numpy.zeros(ndata, numpy.float)
    ## Pre-compute sines, cossines and powers
    #sinlatc = numpy.sin(latc)
    #coslatc = numpy.cos(latc)
    ## Start the numerical integration
    #for l in range(ndata):
        #sinlat = sin(lats[l])
        #coslat = cos(lats[l])
        #radii_sqr = radii[l]**2
        #for i in range(2):
            #coslon = cos(lons[l] - lonc[i])
            #sinlon = sin(lonc[i] - lons[l])
            #for j in range(2):
                #cospsi = sinlat*sinlatc[j] + coslat*coslatc[j]*coslon
                #for k in range(2):
                    #l_sqr = (radii_sqr + rc[k]**2 -
                             #2.*radii[l]*rc[k]*(
                                #sinlat*sinlatc[j] + coslat*coslatc[j]*coslon))
                    #kappa = (rc[k]**2)*coslatc[j]
                    #deltay = rc[k]*coslatc[j]*sinlon
                    #deltaz = rc[k]*cospsi - radii[l]
                    #result[l] = result[l] + (weights[i]*weights[j]*weights[k]*
                        #kappa*3.*deltay*deltaz/(l_sqr**2.5))
        #result[l] = result[l]*scale
    #return result

@cython.boundscheck(False)
@cython.wraparound(False)
def gzz(tesseroid,
    double density,
    numpy.ndarray[double, ndim=1] lons,
    numpy.ndarray[double, ndim=1] sinlats,
    numpy.ndarray[double, ndim=1] coslats,
    numpy.ndarray[double, ndim=1] radii,
    numpy.ndarray[double, ndim=1] lonc,
    numpy.ndarray[double, ndim=1] sinlatc,
    numpy.ndarray[double, ndim=1] coslatc,
    numpy.ndarray[double, ndim=1] rc,
    numpy.ndarray[double, ndim=1] result,
    numpy.ndarray[long, ndim=1] points):
    """
    Integrate gzz using the Gauss-Legendre Quadrature
    """
    cdef:
        unsigned int i, j, k, l, p
        double scale, kappa, sinlat, coslat, radii_sqr, coslon, l_sqr
        double cospsi, deltaz
    # Put the nodes in the corrent range
    scale = _scale_nodes(tesseroid, lonc, sinlatc, coslatc, rc)
    # Start the numerical integration
    for p in range(len(points)):
        l = points[p]
        sinlat = sinlats[l]
        coslat = coslats[l]
        radii_sqr = radii[l]**2
        for i in range(2):
            coslon = cos(lons[l] - lonc[i])
            for j in range(2):
                cospsi = sinlat*sinlatc[j] + coslat*coslatc[j]*coslon
                for k in range(2):
                    l_sqr = (radii_sqr + rc[k]**2 -
                             2.*radii[l]*rc[k]*(
                                sinlat*sinlatc[j] + coslat*coslatc[j]*coslon))
                    kappa = (rc[k]**2)*coslatc[j]
                    deltaz = rc[k]*cospsi - radii[l]
                    result[l] += density*scale*(
                        kappa*(3.*deltaz**2 - l_sqr)/(l_sqr**2.5))
