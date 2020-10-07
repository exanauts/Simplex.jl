
const INF = 1.0e+20
const EPS = 1.0e-6

isGT(x::Real, y::Real, tol::Real = EPS)::Bool = (x - y > +tol)
isGE(x::Real, y::Real, tol::Real = EPS)::Bool = (x - y >= -tol)
isLE(x::Real, y::Real, tol::Real = EPS)::Bool = (x - y <= +tol)
isLT(x::Real, y::Real, tol::Real = EPS)::Bool = (x - y < -tol)
isEQ(x::Real, y::Real, tol::Real = EPS)::Bool = (abs(x-y) <= tol)
isPositive(x::Real, tol::Real = EPS)::Bool = (x > tol)
isNonNegative(x::Real, tol::Real = EPS)::Bool = (x >= -tol)
isNonPositive(x::Real, tol::Real = EPS)::Bool = (x < tol)
isNegative(x::Real, tol::Real = EPS)::Bool = (x < -tol)
isInf(x::Real, tol::Real = INF)::Bool = (x > tol)
isFinite(x::Real, tol::Real = INF)::Bool = (abs(x) < tol)
isZero(x::Real, tol::Real = EPS)::Bool = (abs(x) < EPS)
