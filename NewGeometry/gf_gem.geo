Include "gf_functions.geo";

// GEM layers parameters
NTOT = 1;
ID = 0;

// All parameters in mm
X = 0; Y = 0; Z = 0;    // Center of GEM
DIST = 0.14;            // Distance between holes

// Copper plates
R1 = 0.035;             // Radius of upper plate
R2 = 0.035;             // Radius of lower plate
TPLA1 = 0.005;          // Thickness of upper plate
TPLA2 = 0.005;          // Thickness of lower plate

// Dieletric
NDIE = 3;                      // Number of dieletric planes
POSDIE = {0.025, 0, -0.025};   // Positions of dieletric planes
RDIE = {0.035, 0.025, 0.035};  // Radius of each dieletric plane

// Chamber
DRI = .3;                      // Size of drift region
IND = .1;                      // Size of induction region

// Mesh Quality
lC_CHA = 0.1;


// Debugging
UPPLATE_BOOL = 1;
DIE_BOOL = 1;
LOPLATE_BOOL = 1;
CHAMBER_BOOL = 1;
PHYSICAL_BOOL = 1;


Function gf_gem

  TDIE = POSDIE[0] - POSDIE[NDIE - 1];  // Thickness of dieletric
  X0 = X; Y0 = Y;

  // Checking for "ring border"
  // If there is any, more surfaces are necessary to define the gas volume
  If (RDIE[0] != R1)
    RINGUP = 1;
  Else
    RINGUP = 0;
  EndIf

  If (RDIE[NDIE - 1] != R2)
    RINGLO = 1;
  Else
    RINGLO = 0;
  EndIf


  // Up Plate
  If (UPPLATE_BOOL)
    outup = {};
    pmin = newp; lmin = newl;
    Z0 = Z + TDIE / 2 + TPLA1; R = R1; D = DIST; Call gf_plane;
    Z0 = Z + TDIE / 2; Call gf_plane;
    Call VerticalLines;
    Call Loops;
    slup = loops[];
    outup += {up_gemplane};
    outup += outsideloops[];
    vup = gemv;
    If (RINGUP)
      llringup = up_outerll;
    EndIf
  EndIf


  // Dieletric
  If (DIE_BOOL)
    outdie = {};
    vdie_a = {};

    For j In {0 : NDIE - 2}
      pmin = newp; lmin = newl;
      Z0 = Z + POSDIE[j]; R = RDIE[j];
      Call gf_plane;
      Z0 = Z + POSDIE[j + 1]; R = RDIE[j + 1];
      Call gf_plane;
      Call VerticalLines;
      Call Loops;

      outdie += outsideloops[];

      If (RINGUP && j == 0)
        llringup_die = up_outerll;
      EndIf
      If (RINGLO && j == NDIE - 2)
        llringlo_die += lo_outerll;
      EndIf

      vdie_a += {gemv};
    EndFor
  EndIf


  // Low Plate
  If (LOPLATE_BOOL)
    pmin = newp; lmin = newl;
    Z0 = Z - TDIE / 2; R = R2; Call gf_plane;
    Z0 = Z - TDIE / 2 - TPLA2; Call gf_plane;
    Call VerticalLines;
    Call Loops;
    sllo = loops[];
    outlo = outsideloops[];
    outlo += {lo_gemplane};
    vlo = gemv;
    If (RINGLO)
      llringlo = lo_outerll;
    EndIf
  EndIf


  // Chamber
  If (CHAMBER_BOOL)
    ZTOP = Z + TDIE / 2 + TPLA1 + DRI; ZBOT = Z - TDIE / 2 - TPLA2 - IND; lc = LC_CHA;
    pC1 = newp; Point(pC1) = {X1, Y1, ZTOP, lc}; // Mid Up-Left
    pC2 = newp; Point(pC2) = {X4, Y1, ZTOP, lc}; // Mid Up-Right
    pC3 = newp; Point(pC3) = {X4, Y4, ZTOP, lc}; // Mid Down-Right
    pC4 = newp; Point(pC4) = {X1, Y4, ZTOP, lc}; // Mid Down-Left
    pC5 = newp; Point(pC5) = {X1, Y1, ZBOT, lc}; // Mid Up-Left
    pC6 = newp; Point(pC6) = {X4, Y1, ZBOT, lc}; // Mid Up-Right
    pC7 = newp; Point(pC7) = {X4, Y4, ZBOT, lc}; // Mid Down-Right
    pC8 = newp; Point(pC8) = {X1, Y4, ZBOT, lc}; // Mid Down-Left

    lC1 = newl; Line(lC1) = {pC1, pC2};
    lC2 = newl; Line(lC2) = {pC2, pC3};
    lC3 = newl; Line(lC3) = {pC3, pC4};
    lC4 = newl; Line(lC4) = {pC4, pC1};
    lC5 = newl; Line(lC5) = {pC5, pC6};
    lC6 = newl; Line(lC6) = {pC6, pC7};
    lC7 = newl; Line(lC7) = {pC7, pC8};
    lC8 = newl; Line(lC8) = {pC8, pC5};
    lC9 = newl; Line(lC9) = {pC1, pC5};
    lC10 = newl; Line(lC10) = {pC2, pC6};
    lC11 = newl; Line(lC11) = {pC3, pC7};
    lC12 = newl; Line(lC12) = {pC4, pC8};

    lp1 = newll; Line Loop(lp1) = {lC1, lC2, lC3, lC4};
    s1 = news; Plane Surface(s1) = {lp1};               // +Z
    lp2 = newll; Line Loop(lp2) = {lC5, lC6, lC7, lC8};
    s2 = news; Plane Surface(s2) = {lp2};               // -Z
    lp3 = newll; Line Loop(lp3) = {lC1, lC10, -lC5, -lC9};
    s3 = news; Plane Surface(s3) = {lp3, bnd_ll1[]};    // +Y
    lp4 = newll; Line Loop(lp4) = {lC2, lC11, -lC6, -lC10};
    s4 = news; Plane Surface(s4) = {lp4, bnd_ll2[]};    // +X
    lp5 = newll; Line Loop(lp5) = {lC3, lC12, -lC7, -lC11};
    s5 = news; Plane Surface(s5) = {lp5, bnd_ll3[]};    // -Y
    lp6 = newll; Line Loop(lp6) = {lC4, lC9, -lC8, -lC12};
    s6 = news; Plane Surface(s6) = {lp6, bnd_ll4[]};    // -X
  EndIf

  If (PHYSICAL_BOOL)
    // Boundaries
    // Index must be fixed for multigem
    index_fixed = 100000;
    Physical Surface(index_fixed) = {s3, bnd_s1[]};     // +Y
    Physical Surface(index_fixed + 1) = {s4, bnd_s2[]}; // +X
    Physical Surface(index_fixed + 2) = {s5, bnd_s3[]}; // -Y
    Physical Surface(index_fixed + 3) = {s6, bnd_s4[]}; // -X


    // Physical Surfaces (Potential)
    idreg = 2 * index_fixed + 8 * ID;
    If (ID == 0)
      Physical Surface(idreg) = {s1};       // +Z
      Printf("Part of the first detector layer");
    EndIf
    Physical Surface(idreg + 1) = slup[];   // Upper Plate
    Physical Surface(idreg + 2) = sllo[];   // Lower Plate
    If (ID == NTOT - 1)
      Physical Surface(idreg + 3) = {s2};   // -Z
      Printf("Part of the last detector layer");
    EndIf


    // Physical Volumes
    index_v = 3 * index_fixed;
    Physical Volume(index_v) = {vdie_a[]};
    Physical Volume(index_v + 1) = {vup};
    Physical Volume(index_v + 2) = {vlo};


    // Before defining the gas volume, we apply coherence so any duplicated entity
    // won't affect the generation of the mesh
    Coherence;


    array = {s1, s3, s4, s5, s6, s2};
    array += outup[];
    If (RINGUP)
      ringup = news; Plane Surface(ringup) = {llringup_die, llringup};
      array += {ringup};
    EndIf
    array += outdie[];
    If (RINGLO)
      ringlo = news; Plane Surface(ringlo) = {llringlo_die, llringlo};
      array += {ringlo};
    EndIf
    array += outlo[];
    sl = newsl; Surface Loop(sl) = array[];
    vchamber = newv; Volume(vchamber) = {sl};
    Physical Volume(index_v + 3) = {vchamber};


    // Help to visualize each volume
    Color Orange {Volume{vup, vlo};}
    Color Grey {Volume{vdie_a[]};}
    Color Green {Volume{vchamber};}
  EndIf

Return
