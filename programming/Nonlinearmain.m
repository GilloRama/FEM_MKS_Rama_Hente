% Problem :  Nonlinear bending Analysis of  Mindlin plate  
% This is main program.
% Two Boundary conditions are used, simply supported and clamped
%--------------------------------------------------------------------------
% Code written by authors: Amit Patil, E-mail :Amit Patil,aspatil07@gmail.com 
%                          Siva Srinivas Kolukula, Email:allwayzitzme@gmail.com                                        
%--------------------------------------------------------------------------
%----------------------------------------------------------------------------
%
% Variable descriptions                                                      
%   ke = element stiffness matrix                                             
%   kb = element stiffness matrix for bending
%   ks = element stiffness matrix for shear 
%   f = element force vector
%   stiffness = system stiffness matrix                                             
%   force = system force vector                                                 
%   displacement = system nodal displacement vector
%   coordinates = coordinate values of each node
%   nodes = nodal connectivity of each element
%   index = vector containing system dofs associated with each element     
%   pointb = matrix containing sampling points for bending term
%   weightb = vector containing weighting coefficients for bending term
%   points = matrix containing sampling points for shear term
%   weights = vector containing weighting coefficients for shear term
%   bcdof =  vector containing dofs associated with boundary conditions                                                  
%   B_pb = kinematic matrix for bending
%   D_pb = material matrix for bending
%   B_ps = kinematic matrix for shear
%   D_ps = material matrix for shear
%
%----------------------------------------------------------------------------                  
clear 
clc
disp('Please wait')
%--------------------------------------------------------------------------
% Transverse uniform pressure on plate in steps
%--------------------------------------------------------------------------
Pfinal=300;  % Final load value
loadstepno=5;  % Number of steps to achieve final load
lambda=1/loadstepno;
deltaP = -lambda*Pfinal ; 

store(1,1)=0;
store(1,2)=0;

%--------------------------------------------------------------------------
% Geometrical  properties of plate
%--------------------------------------------------------------------------
a = 1;                            % length of the plate (along X-axis)
b = 1 ;                           % breadth of the plate (along Y-axis)
E = 10920;                        % elastic modulus
nu = 0.3;                         % poisson's ratio
t = 0.1;                        % plate thickness

%Number of mesh element in x and y direction
Nx=5;
Ny=5;
%--------------------------------------------------------------------------
% Input data for nodal connectivity for each element
%--------------------------------------------------------------------------

[coordinates, nodes] = MeshRectanglularPlate(a,b,Nx,Ny,1) ; % for node connectivity counting starts from 1 towards +y axis and new row again start at x=0.


nel = length(nodes) ;                  % number of elements
nnel=4;                                % number of nodes per element
ndof=5;                                % number of dofs per node
nnode = length(coordinates) ;          % total number of nodes in system
sdof=nnode*ndof;                       % total system dofs  
edof=nnel*ndof;                        % degrees of freedom per element

P=0;                                   % setting force equal to zero initially and displacement is also zero. This is reference state and equilibrium configuration
u=zeros(nnode,1);                      % nodal displacement vector is a={u,v,w,thithax,thithay}                                                                                                                           
v=zeros(nnode,1);
w=zeros(nnode,1);
tithax=zeros(nnode,1);
tithay=zeros(nnode,1);
displacement=zeros(5*nnode,1);
 
 for loadstep=1:loadstepno  % This loop is for geometrically nonlinear plate, here equilibrium equation is linearized at equilibrium solution.  Here load is increased in steps.
     
     P=P+deltaP;
     
     disp(P);
     
%--------------------------------------------------------------------------
% Boundary conditions
%--------------------------------------------------------------------------
%typeBC = 'ss-ss-ss-ss' ;        % boundary Condition type simply supported or clamped
typeBC = 'c-c-c-c'   ;    

for updateintforce=1:5  % This is loop for Newton-Raphson method

   


[stiffness,tangentstiffness,force,bcdof]=SDF(P,E,nu,t,coordinates, nodes,nel,nnel,ndof,sdof,edof,displacement,typeBC,loadstep,updateintforce); 
% Here we are getting stiffness, tangentstiffness, force and boundary conditions matix/vectors


totaldof=1:sdof;
activedof=setdiff(totaldof,bcdof);
deltadisplacement=zeros(sdof,1);
 


    residual=stiffness(activedof,activedof)*displacement(activedof)-force(activedof);
    residualnorm=norm(residual)
    deltadisplacement(activedof) = -tangentstiffness(activedof,activedof)\residual;
    displacement=displacement+deltadisplacement;
    norm(deltadisplacement);

    

u = displacement(1:5:sdof) ;
v = displacement(2:5:sdof) ;
w = displacement(3:5:sdof) ;
tithax = displacement(4:5:sdof) ;
tithay = displacement(5:5:sdof) ;

 if residualnorm<10^-3
     break;
 end

end


%--------------------------------------------------------------------------
% Output of displacements
%--------------------------------------------------------------------------

%[u,v,w,titax,titay] = mytable(nnode,displacement,sdof) ;
% Maximum transverse displacement
format long 
minw = min(w)
store(loadstep+1,1)=P;
store(loadstep+1,2)=minw;
 end

%--------------------------------------------------------------------------
% Deformed Shape after final iterations
%--------------------------------------------------------------------------

% x = coordinates(:,1) ;
% y = coordinates(:,2) ;
% f3 = figure ;
% set(f3,'name','Postprocessing','numbertitle','off') ;
% plot3(x,y,w,'.') ;
% title('plate deformation') ;

% -----------------------------------------------------------------------

plot(-store(:,1),-store(:,2),'LineWidth',2);
title('Equilibrium path') ;
xlabel('-P')
ylabel('-w')

%--------------------------------------------------------------------------
% Deformed mesh Plots
%--------------------------------------------------------------------------

 PlotFieldonDefoMesh(coordinates,nodes,w,w)
 title('Profile of w on deformed Mesh')  


% Contour Plots
%--------------------------------------------------------------------------
 PlotFieldonMesh(coordinates,nodes,u)
 title('Profile of u on plate')
 PlotFieldonMesh(coordinates,nodes,v)
 title('Profile of v on plate')
 PlotFieldonMesh(coordinates,nodes,w)
 title('Profile of w on plate')

