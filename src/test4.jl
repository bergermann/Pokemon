A = ones(Int,10,10)

display(A)

nx, ny = 5,4
x,y = 2,5
B = zeros(Int,ny,nx)

# A[y:y+ny-1,x:x+nx-1] = B
A[max(1,y):min(10,y+ny-1),max(1,x):min(10,x+nx-1)] = 
    B[max(1,-y+2):min(ny,10-(y+ny)+2),
    max(1,-x+2):min(nx,10-(x+nx)+2)]

display(A)



A = ones(Int,10,10)

display(A)

nx, ny = 5,3
x,y = 2,3
B = zeros(Int,ny,nx)

v = view(A,y:y+ny-1,x:x+nx-1)

#v .= B

for i in eachindex(v)
    v[i] = B[i]
end

display(A)

A[maximum(1,y):minimum(10,y+ny-1),maximum(1,x):minimum(10,x+nx-1)] = 
    B[maximum(1,-y+2):minimum(ny,10-(y+ny)+2),
    maximum(1,-x+2):minimum(nx,10-(x+nx)+2)]