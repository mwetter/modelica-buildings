within Buildings.Fluid.HeatExchangers.BaseClasses;
model PartialHexElement "Element of a heat exchanger 2"
  extends Buildings.Fluid.Interfaces.FourPortHeatMassExchanger;

  parameter Boolean initialize_p1 = not Medium1.singleState
    "Set to true to initialize the pressure of volume 1"
    annotation(HideResult=true, Evaluate=true, Dialog(tab="Advanced"));
  parameter Boolean initialize_p2 = not Medium2.singleState
    "Set to true to initialize the pressure of volume 2"
    annotation(HideResult=true, Evaluate=true, Dialog(tab="Advanced"));

  parameter Modelica.SIunits.ThermalConductance UA_nominal
    "Thermal conductance at nominal flow, used to compute time constant"
     annotation(Dialog(group = "Nominal condition"));
  parameter Modelica.SIunits.Time tau_m(min=0) = 60
    "Time constant of metal at nominal UA value"
          annotation(Dialog(tab="General", group="Nominal condition",
          enable=not (energyDynamics == Modelica.Fluid.Types.Dynamics.SteadyStateInitial)));
  parameter Modelica.SIunits.HeatCapacity C=2*UA_nominal*tau_m
    "Heat capacity of metal (= cp*m)";

  parameter Boolean use_freezeProtection = false
    "Flag, set to true to enable freeze protection"
    annotation(Dialog(tab="Experimental"));
  Modelica.Blocks.Interfaces.RealInput Gc_1
    "Signal representing the convective thermal conductance medium 1 in [W/K]"
    annotation (Placement(transformation(
        origin={-40,100},
        extent={{-20,-20},{20,20}},
        rotation=270)));
  Modelica.Blocks.Interfaces.RealInput Gc_2
    "Signal representing the convective thermal conductance medium 2 in [W/K]"
    annotation (Placement(transformation(
        origin={40,-100},
        extent={{-20,-20},{20,20}},
        rotation=90)));

  Modelica.Thermal.HeatTransfer.Components.HeatCapacitor mas(
    C=C,
    T(stateSelect=StateSelect.always,
      fixed=(energyDynamics == Modelica.Fluid.Types.Dynamics.FixedInitial)),
    der_T( fixed=(energyDynamics == Modelica.Fluid.Types.Dynamics.SteadyStateInitial))) if
       not (energyDynamics == Modelica.Fluid.Types.Dynamics.SteadyState)
    "Mass of metal"
    annotation (Placement(transformation(
        origin={-82,0},
        extent={{-10,-10},{10,10}},
        rotation=90)));

  Modelica.Thermal.HeatTransfer.Components.Convection con1(dT(min=-200))
    "Convection (and conduction) on fluid side 1"
    annotation (Placement(transformation(extent={{-50,50},{-30,70}})));
  Modelica.Thermal.HeatTransfer.Components.Convection con2(dT(min=-200))
    "Convection (and conduction) on fluid side 2"
    annotation (Placement(transformation(extent={{-50,-30},{-30,-50}})));
protected
  FreezeProtection frePro(QMax_flow=1E-2*UA_nominal) if use_freezeProtection
    "Model to avoid freezing the water, which may happen if wind pressure induces air when the fans are off"
    annotation (Placement(transformation(rotation=0, extent={{30,70},{50,90}})));
equation
  connect(Gc_1, con1.Gc) annotation (Line(points={{-40,100},{-40,76},{-40,70}},
                    color={0,0,127}));
  connect(Gc_2, con2.Gc) annotation (Line(points={{40,-100},{40,-76},{-40,-76},
          {-40,-50}},                   color={0,0,127}));
  connect(con1.solid,mas. port) annotation (Line(points={{-50,60},{-66,60},{-66,
          0},{-70,0},{-72,0},{-72,-6.12323e-16}},
                           color={191,0,0}));
  connect(con1.fluid, vol1.heatPort) annotation (Line(
      points={{-30,60},{-10,60}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(con2.fluid, vol2.heatPort) annotation (Line(
      points={{-30,-40},{20,-40},{20,-60},{12,-60}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(con2.solid, con1.solid) annotation (Line(
      points={{-50,-40},{-66,-40},{-66,60},{-50,60}},
      color={191,0,0},
      smooth=Smooth.None));
protected
  model FreezeProtection
    "Model to avoid freezing the coil at very low flow rates"
    extends Modelica.Blocks.Icons.Block;

    parameter Modelica.SIunits.HeatFlowRate QMax_flow(min=0)
      "Maximum heat flow rate that is added";

    Buildings.HeatTransfer.Sources.PrescribedHeatFlow preHeaFlo
      "Prescribed heat flow rate"
      annotation (Placement(transformation(extent={{50,40},{70,60}})));
    Modelica.Blocks.Math.Gain gai(final k=QMax_flow)
      "Gain for injected heat if temperature gets close to freezing"
      annotation (Placement(transformation(extent={{20,40},{40,60}})));
    Modelica.Blocks.Math.Feedback feedback "Temperature error below set point"
      annotation (Placement(transformation(extent={{-50,40},{-30,60}})));
    Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor temSen
      "Temperature sensor"
      annotation (Placement(transformation(extent={{-80,10},{-60,30}})));
    Modelica.Blocks.Sources.Constant const(k=273.15 + 3) "Set point temperature"
      annotation (Placement(transformation(extent={{-80,40},{-60,60}})));
    Modelica.Blocks.Nonlinear.Limiter lim(final uMax=1, final uMin=0)
      "Limiter to ensure that heat is only added"
      annotation (Placement(transformation(extent={{-18,40},{2,60}})));

    Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_b port annotation (
        Placement(transformation(rotation=0, extent={{-112,-10},{-92,10}}),
          iconTransformation(extent={{-110,-10},{-90,10}})));

  equation
    connect(preHeaFlo.Q_flow, gai.y)
      annotation (Line(points={{50,50},{41,50}}, color={0,0,127}));
    connect(gai.u, lim.y)
      annotation (Line(points={{18,50},{3,50}}, color={0,0,127}));
    connect(feedback.y, lim.u)
      annotation (Line(points={{-31,50},{-31,50},{-20,50}}, color={0,0,127}));
    connect(feedback.u1,const. y)
      annotation (Line(points={{-48,50},{-54,50},{-59,50}},    color={0,0,127}));
    connect(temSen.T, feedback.u2)
      annotation (Line(points={{-60,20},{-40,20},{-40,42}}, color={0,0,127}));
    connect(port, preHeaFlo.port) annotation (Line(points={{-102,0},{80,0},{80,50},
            {70,50}}, color={191,0,0}));
    connect(port, temSen.port) annotation (Line(points={{-102,0},{-88,0},{-88,20},
            {-80,20}}, color={191,0,0}));
  end FreezeProtection;
equation
  connect(frePro.port, vol1.heatPort) annotation (Line(points={{30,80},{26,80},
          {26,40},{-20,40},{-20,60},{-10,60}}, color={191,0,0}));
  annotation (
    Documentation(info="<html>
<p>
Element of a heat exchanger
with dynamics of the fluids and the solid.
The <i>hA</i> value for both fluids is an input.
The driving force for the heat transfer is the temperature difference
between the fluid volumes and the solid.
</p>
<p>
The heat capacity <i>C</i> of the metal is assigned as follows.
Suppose the metal temperature is governed by
</p>
<p align=\"center\" style=\"font-style:italic;\">
  C dT &frasl; dt = (hA)<sub>1</sub> (T<sub>1</sub> - T)
  + (hA)<sub>2</sub> (T<sub>2</sub> - T)
</p>
<p>
where <i>hA</i> are the convective heat transfer coefficients times
heat transfer area that also take
into account heat conduction in the heat exchanger fins and
<i>T<sub>1</sub></i> and <i>T<sub>2</sub></i> are the medium temperatures.
Assuming <i>(hA)<sub>1</sub>=(hA)<sub>2</sub></i>,
this equation can be rewritten as
</p>
<p align=\"center\" style=\"font-style:italic;\">
  C dT &frasl; dt =
  2 (UA)<sub>0</sub> ( (T<sub>1</sub> - T) + (T<sub>2</sub> - T) )

</p>
<p>
where <i>(UA)<sub>0</sub></i> is the <i>UA</i> value at nominal conditions.
Hence we set the heat capacity of the metal
to
</p>
<p align=\"center\" style=\"font-style:italic;\">
C = 2 (UA)<sub>0</sub> &tau;<sub>m</sub>
</p>
<p>
where <i>&tau;<sub>m</sub></i> is the time constant that the metal
of the heat exchanger has if the metal is approximated by a lumped
thermal mass.
</p>
<p>
<b>Note:</b> This model is introduced to allow the instances
<a href=\"modelica://Buildings.Fluid.HeatExchangers.BaseClasses.HexElementLatent\">
Buildings.Fluid.HeatExchangers.BaseClasses.HexElementLatent
</a>
and
<a href=\"modelica://Buildings.Fluid.HeatExchangers.BaseClasses.HexElementSensible\">
Buildings.Fluid.HeatExchangers.BaseClasses.HexElementSensible
</a>
to redeclare the volume as <code>final</code>, thereby avoiding
that a GUI displays the volume as a replaceable component.
</p>
</html>",
revisions="<html>
<ul>
<li>
October 19, 2017, by Michael Wetter:<br/>
Changed initialization of pressure from a <code>constant</code> to a <code>parameter</code>.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/1013\">Buildings, issue 1013</a>.
</li>
<li>
July 17, 2015, by Michael Wetter:<br/>
Added <code>prescribedHeatFlowRate=false</code> for both volumes.
This is for
<a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/282\">
issue 282</a> of the Annex 60 library.
</li>
<li>
February 5, 2015, by Michael Wetter:<br/>
Changed <code>initalize_p</code> from a <code>parameter</code> to a
<code>constant</code>. This is only required in finite volume models
of heat exchangers (to avoid consistent but redundant initial conditions)
and hence it should be set as a <code>constant</code>.
</li>
<li>
July 3, 2014, by Michael Wetter:<br/>
Added parameters <code>initialize_p1</code> and <code>initialize_p2</code>.
This is required to enable the coil models to initialize the pressure in the
first volume, but not in the downstream volumes. Otherwise,
the initial equations will be overdetermined, but consistent.
This change was done to avoid a long information message that appears
when translating models.
</li>
<li>
July 2, 2014, by Michael Wetter:<br/>
Conditionally removed the mass of the metall <code>mas</code>.
</li>
<li>
June 26, 2014, by Michael Wetter:<br/>
Removed parameters <code>energyDynamics1</code> and <code>energyDynamics2</code>,
and used instead of these two parameters <code>energyDynamics</code>.
This was done as this complexity is not required.
</li>
<li>
September 11, 2013, by Michael Wetter:<br/>
Separated old model into one for dry and for wet heat exchangers.
This was done to make the coil compatible with OpenModelica.
</li>
<li>
May 1, 2013, by Michael Wetter:<br/>
Changed the redeclaration of <code>vol2</code> to be replaceable,
as <code>vol2</code> is replaced in some models.
</li>
<li>
April 19, 2013, by Michael Wetter:<br/>
Made instance <code>MassExchange</code> replaceable, rather than
conditionally removing the model, to avoid a warning
during translation because of unused connector variables.
</li>
<li>
July 11, 2011, by Michael Wetter:<br/>
Removed assignment of medium in <code>vol1</code> and <code>vol2</code>,
since this assignment is already done in the base class using the
<code>final</code> modifier.
</li>
<li>
August 12, 2008, by Michael Wetter:<br/>
Introduced option to compute each medium using a steady state model or
a dynamic model.
</li>
<li>
March 25, 2008, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"),    Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,
            100}}), graphics={Text(
          extent={{-84,114},{-62,86}},
          lineColor={0,0,255},
          textString="h"), Text(
          extent={{58,-92},{84,-120}},
          lineColor={0,0,255},
          textString="h")}));
end PartialHexElement;
