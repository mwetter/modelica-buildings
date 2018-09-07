within Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant;
block LeadLag "Equipment staging and rotation to maintain even wear"
  parameter Integer num = 2
    "Total number of devices";

  CDL.Interfaces.IntegerInput uChiSta "Chiller stage count input"
    annotation (Placement(transformation(extent={{-180,-100},{-140,-60}}),
      iconTransformation(extent={{100,-10},{120,10}})));
  CDL.Interfaces.BooleanInput                        uDevSta[num]
    "Current devices operation status"
    annotation (Placement(transformation(extent={{-180,20},{-140,60}}),
      iconTransformation(extent={{-140,-20},{-100,20}})));
  CDL.Interfaces.BooleanOutput                        yDevSta[num]
    "Devices status after enabling one more device"
    annotation (Placement(transformation(extent={{140,20},{180,60}}),
      iconTransformation(extent={{100,-10},{120,10}})));
  CDL.Interfaces.IntegerInput yChiSta "Chiller stage count output"
    annotation (Placement(transformation(extent={{120,-100},{160,-60}})));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-140,-140},
            {140,140}})), Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-140,-140},{140,140}})));
end LeadLag;
