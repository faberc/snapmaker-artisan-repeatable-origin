/**
  Copyright (C) 2016-2017 by Snapmaker, Inc.
  All rights reserved.

   Snapmaker (Marlin) post processor configuration.
   Modified for Parameter-Based Clearance Height & Safety Z-Lift.
*/

description = "Generic Snapmaker (Marlin) - With RPM and Safe Z Clearance";
vendor = "SNAPMAKER";
vendorUrl = "http://www.snapmaker.com";
legal = "Copyright (C) 2016-2018 by Snapmaker, Inc. modded by Gemini";
certificationLevel = 2;
minimumRevision = 24000;

longDescription = "Generic milling post for Snapmaker. Uses raw parameters for Clearance Height to ensure compatibility.";

extension = ".cnc";
setCodePage("ascii");

capabilities = CAPABILITY_MILLING;
tolerance = spatial(0.002, MM);

minimumChordLength = spatial(0.01, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(180);
allowHelicalMoves = true;
allowedCircularPlanes = 0; // circular interpolation is not supported

properties = {
  writeMachine: true,
  showSequenceNumbers: false,
  sequenceNumberStart: 10,
  sequenceNumberIncrement: 1,
  separateWordsWithSpace: true
};

var gFormat = createFormat({prefix:"G", decimals:0});
var mFormat = createFormat({prefix:"M", decimals:0});
var xyzFormat = createFormat({decimals:(unit == MM ? 3 : 4), trim:false});
var feedFormat = createFormat({decimals:(unit == MM ? 1 : 2)});
var secFormat = createFormat({decimals:3, forceDecimal:true});

var xOutput = createVariable({prefix:"X", force:true}, xyzFormat);
var yOutput = createVariable({prefix:"Y", force:true}, xyzFormat);
var zOutput = createVariable({prefix:"Z", force:true}, xyzFormat);
var feedOutput = createVariable({prefix:"F", force:true}, feedFormat);

var iOutput = createVariable({prefix:"I", force:true}, xyzFormat);
var jOutput = createVariable({prefix:"J", force:true}, xyzFormat);

var gMotionModal = createModal({force:true}, gFormat);
var gAbsIncModal = createModal({}, gFormat);
var gUnitModal = createModal({}, gFormat);

var sequenceNumber;
var currentWorkOffset;

function writeBlock() {
  if (properties.showSequenceNumbers) {
    writeWords2("N" + sequenceNumber, arguments);
    sequenceNumber += properties.sequenceNumberIncrement;
  } else {
    writeWords(arguments);
  }
}

function formatComment(text) {
  return ";" + String(text).replace(/[\(\)]/g, "");
}

function writeComment(text) {
  writeln(formatComment(text));
}

function onOpen() {
  if (!properties.separateWordsWithSpace) {
    setWordSeparator("");
  }
  sequenceNumber = properties.sequenceNumberStart;
  if (programName) { writeComment(programName); }
  if (programComment) { writeComment(programComment); }

  writeBlock("G4 S2"); // dwell 2 seconds
  switch (unit) {
    case IN:
      error(localize("Please select millimeters."));
      return;
    case MM:
      writeBlock(gUnitModal.format(21));
      break;
  }
  writeBlock(gAbsIncModal.format(90));
  forceXYZ();
}

function onComment(message) {
  writeComment(message);
}

function forceXYZ() {
  xOutput.reset();
  yOutput.reset();
  zOutput.reset();
}

function forceAny() {
  forceXYZ();
  feedOutput.reset();
}

function onSection() {
  writeln("");
  if (hasParameter("operation-comment")) {
    var comment = getParameter("operation-comment");
    if (comment) { writeComment(comment); }
  }

  forceXYZ();

  {
    var remaining = currentSection.workPlane;
    if (!isSameDirection(remaining.forward, new Vector(0, 0, 1))) {
      error(localize("Tool orientation is not supported."));
      return;
    }
    setRotation(remaining);
  }

  forceAny();

// 1. SAFETY LIFT: Use the standard parameter name
  var zClearance = 30; // Default safety fallback
  
  if (hasParameter("clearanceHeight")) {
    zClearance = getParameter("clearanceHeight");
  } else if (currentSection.getInitialPosition()) {
    zClearance = currentSection.getInitialPosition().z;
  }
  
  writeBlock(gAbsIncModal.format(90), gMotionModal.format(0), zOutput.format(zClearance));

  // 2. START SPINDLE
  var rpm = getSpindleSpeed();
  var pValue = Math.round(rpm / 18000 * 100);
  pValue = clamp(0, pValue, 100);
  writeBlock("M3 P" + pValue);
  writeBlock("G4 S2");

  // 3. JOG TO XY
  var initialPosition = getFramePosition(currentSection.getInitialPosition());
  writeBlock(
    gMotionModal.format(0),
    xOutput.format(initialPosition.x),
    yOutput.format(initialPosition.y)
  );
  
  gMotionModal.reset();
}

function onDwell(seconds) {
  seconds = clamp(0.001, seconds, 99999.999);
  writeBlock(gFormat.format(4), "P" + secFormat.format(seconds));
}

function onRapid(_x, _y, _z) {
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  if (x || y || z) {
    writeBlock(gMotionModal.format(0), x, y, z);
    feedOutput.reset();
  }
}

function onLinear(_x, _y, _z, feed) {
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var f = feedOutput.format(feed);
  if (x || y || z) {
    writeBlock(gMotionModal.format(1), x, y, z, f);
  }
}

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  var start = getCurrentPosition();
  switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), feedOutput.format(feed));
      break;
    default:
      linearize(tolerance);
  }
}

function onSectionEnd() {
  forceAny();
}

function onClose() {
  // 1. DYNAMIC SAFETY LIFT: Use the calculated clearance height from the job
  var zClearance = currentSection.getInitialPosition().z;

  // 2. FALLBACK: Use 30 only if the variable is invalid
  if (typeof zClearance !== 'number') {
    zClearance = 30; 
  }
  
  // Move to clearance height first
  writeBlock(gAbsIncModal.format(90), gMotionModal.format(0), zOutput.format(zClearance));
  
  // Move back to the Puck/Rail origin (X0 Y0)
  writeBlock(gMotionModal.format(0), xOutput.format(0), yOutput.format(0));
  
  // Shut down spindle
  writeBlock(mFormat.format(5)); 
}