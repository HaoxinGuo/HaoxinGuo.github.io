###################################################
# File: SmartAnalyze.tcl
# Author: Hanlin Dong
# Create: 2019-06-28 10:42:19
# Version: 2.2
# Last update: 2019-07-12 16:11:26
# License: MIT License (https://opensource.org/licenses/MIT)
# (The latest version can be found on http://www.hanlindong.com/)
# Readme:
#     The SmartAnalyze provides OpenSees users a easier way to carry out analyses.
#     There are two main functions defined in this .tcl file. SmartAnalyzeTransient & SmartAnalyzeStatic.
#     SmartAnalyzeTransient is used to carry out time history analyses.
#         The arguments must be specified are $dt: delta t and $npts: number of points.
#         If the dictionary control is not specified, all the default values will be used.
#         If you want to change the control parameters, please do not modify this tcl file directly. Pass it as an argument.
#         E.g.: (in your model file) 
#             source SmartAnalyze.tcl
#             dict set control testTol 1.0e-4
#             dict set control tryLooseTestTol False
#             SmartAnalyzeTransient $dt $npts control
#         The control parameters are:
#             testType testTol testIterTimes testPrintFlag tryAddTestTimes normTol testIterTimesMore tryLooseTestTol 
#             looseTestTolTo tryAlterAlgoTypes algoTypes tryForceConverge initialStep relaxation minStep printPer
#         For manuals to these parameters, please read the body of the procedure.
#         The basic work flow of SmartAnalyzeTransient:
#             1. Start
#             2. Set initial step length, algorithm method and test (You don't need to specify them in your model.)
#             3. While the current time is smaller than the total time, loop the following
#                 3.1 Trail analyze for one step
#                 3.2 If converge, continue the loop 3
#                 3.3 If not converge, loop to deal with it
#                     3.3.1 If tryAddTestTimes is True, if the last test norm is smaller than normTol, set a larger test time.
#                     3.3.2 If converge, break loop 3.3 and continue the loop 3. If not, go on.
#                     3.3.3 If tryAlterAlgoTypes is True, loop within the algoTypes except the first one (already trailed)
#                         3.3.3.1 Trail analyze for one step. If converge, break the loop and continue to 3.
#                         3.3.3.2 If tryAddTestTimes is True, try to set a larger test time using the same way in 3.3.1
#                     3.3.4 If all the algorithm types can't lead to convergance, try to shortern step length.
#                     3.3.5 Loop while the step length is still larger than the minStep.
#                         3.3.5.1 Trail the new step length. If converge, continue loop 3.
#                         3.3.5.2 If not converge, continue loop 3.3
#                     3.3.6 If step length is smaller than minStep, and still cannot converge, try special way to force converge.
#                     3.3.7 If tryLooseTestTol is True, loose test tolerance to looseTestTolTo. set step to initial, loop again.
#                     3.3.8 If still not converge, and tryForceConverge is True, set algorithm to Linear and force converge.
#                     3.3.9 If still not converge, return with error message.
#             4. If converge, return success message.
#     SmartAnalyzeStatic is used to carry out static analyze.
#     The arguments that must be specified are
#         $node: the node tag in the displacement control
#         $dof: the dof in the displacement control
#         $maxStep: the maximum step length in the displacement control
#         $targets: a list of target displacements. E.g. {1 -1 1 -1 0} will reslut in cyclic load of amplitude 1 twice.
#     The control parameters are similar to the transient one.
# Change Log:
#   2019-06-28 10:42:19 v0.0
#     Create file.
#   2019-06-28 18:04:52 v1.0
#     Created the main transient function SmartAnalyzeTransient
#   2019-07-03 12:27:06 v2.0
#     Created the main static fuction SmartAnalyzeStatic
#   2019-07-10 13:12:21 v2.1
#     Improve user interface and robustness
#   2019-07-12 16:11:26 v2.2
#     Add force converge report at the end of analysis
###################################################

# Control Parameters:
# testType testTol testIterTimes testPrintFlag tryAddTestTimes normTol testIterTimesMore tryLooseTestTol 
# looseTestTolTo tryAlterAlgoTypes algoTypes tryForceConverge initialStep relaxation minStep printPer

# Welcome banner
puts " ********************************************************************** "
puts " *                           WELCOME TO                               * "
puts " *  _____                      _    ___              _                * "
puts " * /  ___|                    | |  / _ \\            | |               * "
puts " * \\ `--. _ __ ___   __ _ _ __| |_/ /_\\ \\_ __   __ _| |_   _ _______  * "
puts " *  `--. \\ '_ ` _ \\ / _` | '__| __|  _  | '_ \\ / _` | | | | |_  / _ \\ * "
puts " * /\\__/ / | | | | | (_| | |  | |_| | | | | | | (_| | | |_| |/ /  __/ * "
puts " * \\____/|_| |_| |_|\\__,_|_|   \\__\\_| |_/_| |_|\\__,_|_|\\__, /___\\___| * "
puts " *                                                      __/ |         * "
puts " *                                                     |___/          * "
puts " * Author: Hanlin DONG (http://www.hanlindong.com)                    * "
puts " * License: MIT (https://opensource.org/licenses/MIT).                * "
puts " ********************************************************************** "

puts "Smart Analyze version 2.2 loaded."
puts "For transient analyze, call SmartAnalyzeTransient dt npts"
puts "For static analyze, call SmartAnalyzeStatic node dof targets maxStep"
puts "Enjoy!"
puts " "

proc SmartAnalyzeTransient { dt npts {controlDict {}}} {
    if {$controlDict != {}} {
        upvar $controlDict control
        puts "User defined control parameters:"
        puts $control
    } else {
        puts "Using default control parameters"
        set control {}
    }
    #################################################
    #####      PARAMETERS RELATED TO TEST       #####
    #################################################
    # testType: string. Identical to the testType in OpenSees test command. Default is "EnergyIncr".
    #     Choices see http://opensees.berkeley.edu/wiki/index.php/Test_Command.
    if { ! [dict exists $control testType] } {
        dict append control testType "EnergyIncr"
    }
    # testTol: float. The initial test tolerance set to the OpenSees test command. Default is 1.0e-6.
    #          If tryLooseTestTol is set to True, the test tolerance can be loosen.
    if { ! [dict exists $control testTol] } {
        dict append control testTol 1.0e-6
    }
    # testIterTimes: integer. The initial number of test iteration times. Default is 7.
    #                If tryAddTestTimes is set to True, the number of test times can be enlarged.
    if { ! [dict exists $control testIterTimes] } {
        dict append control testIterTimes 7
    }
    # testPrintFlag: integer. The test print flag in OpenSees Test command. Default is 0.
    #     Choices see http://opensees.berkeley.edu/wiki/index.php/Test_Command.
    if { ! [dict exists $control testPrintFlag] } {
        dict append control testPrintFlag 0
    }
    # tryAddTestTimes: Boolean. Default is True If this is set to True, 
    #                  the number of test times will be enlarged if the last test norm is not too large depending on `normTol`,
    #                  the enlarged number is specified in `testIterTimesMore`.
    #                  Otherwise, the number of test times will always be equal to `testIterTimes`.
    if { ! [dict exists $control tryAddTestTimes] } {
        dict append control tryAddTestTimes True
    }
    # normTol: Float. Only useful when tryAddTestTimes is True. Default is 1.0e3.
    #                 If unconvergance is encountered, the last norm of test will be compared to `normTol`.
    #                 If the norm is smaller, the number of test times will be enlarged.
    if { ! [dict exists $control normTol] } {
        dict append control normTol 1.0e3
    }
    # testIterTimesMore: Integer. Only useful when tryaddTestTimes is True. Default is 50.
    #                    If unconvergance is encountered and norm is not too large, the number of test times will be set to this number.
    if { ! [dict exists $control testIterTimesMore] } {
        if { [dict get $control tryAddTestTimes] } {
            dict append control testIterTimesMore 50
        } else {
            dict append control testIterTimesMore [dict get $control testIterTimes]
        }
    }
    # tryLooseTestTol: Boolean. If this is set to True, if the unconvergance is encountered at minimum step,
    #                  the test tolerance will be loosen to the number specified by `looseTestTolTo`.
    #                  the step will be set back.
    #                  Default is True.
    if { ! [dict exists $control tryLooseTestTol] } {
        dict append control tryLooseTestTol True
    }
    # looseTestTolTo: Float. Only useful if tryLooseTestTol is True.
    #                 If unconvergance is encountered at the min step, the test tolerance will be set to this value.
    #                 Default is 1.
    if { ! [dict exists $control looseTestTolTo] } {
        dict append control looseTestTolTo 1.
    }
    #################################################
    #####    PARAMETERS RELATED TO ALGORITHM    #####
    #################################################
    # tryAlterAlgoTypes: Boolean. Default is False.
    #                    If it is set to True, different algorithm types specified in `algoTypes` will be tried during unconvergance.
    #                    If it is set to False, the first algorithm type specified in `algoTypes` will be used.
    if { ! [dict exists $control tryAlterAlgoTypes] } {
        dict append control tryAlterAlgoTypes False
    }
    # algoTypes: list of integer. A list of flags of the algorithms to be used during unconvergance.
    #            Only useful when tryAlterAlgoTypes is True. 
    #            The first flag will be used by default. If algorithm command was called in the model, it will be ignored.
    #            Default is { 40 }
    #            If you need other algorithm, try to add a new flag to the `setAlgorithm` procedure at the bottom.
    #            References:
    #             0:  Linear
    #             1:  Linear -initial
    #             2:  Linear -factorOnce
    #            10:  Newton
    #            11:  Newton -initial
    #            12:  Newton -initialThenCurrent
    #            20:  NewtonLineSearch
    #            21:  NewtonLineSearch -type Bisection
    #            22:  NewtonLineSearch -type Secant
    #            23:  NewtonLineSearch -type RegulaFalsi
    #            30:  ModifiedNewton
    #            31:  ModifiedNewton -initial
    #            40:  KrylovNewton
    #            41:  KrylovNewton -iterate initial
    #            42:  KrylovNewton -increment initial
    #            43:  KrylovNewton -iterate initial -increment initial
    #            44:  KrylovNewton -maxDim 6
    #            50:  SecantNewton
    #            51:  SecantNewton -iterate initial
    #            52:  SecantNewton -increment initial 
    #            53:  SecantNewton -iterate initial -increment initial
    #            60:  BFGS
    #            70:  Broyden
    #            80:  User-defined. Try to add your algorithm to the procedure `setAlgorithm`.
    if { ! [dict exists $control algoTypes] } {
        dict append control algoTypes { 40 20 }
    }
    # tryForceConverge: Boolean. Default is True.
    #                   If True, the last step during unconvergance will be setting algorithm to Linear.
    #                   Then the step will surely converge. However, the result may be bad.
    if { ! [dict exists $control tryForceConverge] } {
        dict append control tryForceConverge True
    }
    #################################################
    #####   PARAMETERS RELATED TO STEP LENGTH   #####
    #################################################
    # initialStep: Float. Default is equal to $dt.
    #              Specifying the initial Step length to conduct analysis.
    if { ! [dict exists $control initialStep] } {
        dict append control initialStep $dt
    }
    # relaxation: Float, between 0 and 1. Default is 0.5.
    #                   A factor that is multiplied by each time the step length is shortened.
    if { ! [dict exists $control relaxation] } {
        dict append control relaxation 0.5
    }
    # minStep: Float. Default is 1.0e-6.
    #          The step tolerance when shortening the step length.
    #          If step length is smaller than minStep, special ways to converge the model will be used according to `try-` flags.
    if { ! [dict exists $control minStep] } {
        dict append control minStep 1.0e-6
    }
    #################################################
    #####   PARAMETERS RELATED TO LOGGING       #####
    #################################################
    # printPer: integer. Print to the console every several trials. Default is 1.
    if { ! [dict exists $control printPer] } {
        dict append control printPer 10
    }
    #################################################
    #####                MAIN                   #####
    #################################################
    puts "Smart Analyze control parameters"
    puts $control
    # set counter on loose test tolerance
    set counterLooseTestTol 0
    # set counter on force converge
    set counterForceConverge 0
    # set initial algorithm
    setAlgorithm [lindex [dict get $control algoTypes] 0]
    # set initial test
    test [dict get $control testType] [dict get $control testTol] [dict get $control testIterTimes] [dict get $control testPrintFlag]
    # set initial step length.
    set step [dict get $control initialStep]
    # initialize time cursor
    set currentTime 0
    # initialize converge flag
    set ok 0
    # initialize analyze times counter
    set counter 0
    # store the start time.
    set startTime [clock clicks -millisec]
    # Loop within the given npts
    while { $ok == 0 && $currentTime < [expr $npts * $dt] } {
        if { $counter >= [dict get $control printPer]} {
            # Console output
            puts "* SmartAnalyze:  [format %.4f [expr $currentTime / $npts / $dt * 100]]% Finished. Current time: [format %.4f $currentTime]. Time passed: [expr ([clock clicks -millisec]-$startTime) / 1000.] seconds."
            # setting counter back.
            set counter 0
        }
        # Try analyze once.
        set ok [analyze 1 $step]
        incr counter
        # judge convergance.
        if { $ok == 0 } {
            # converge.
            set currentTime [expr $currentTime + $step]
        } else {
            # Loop. If converge, break the loop.
            while { True } {
                # First check tryAddTestTimes.
                if { [dict get $control tryAddTestTimes] } {
                    # compare the test norms.
                    set norm [testNorms]
                    if { [lindex $norm end] < [dict get $control normTol] } {
                        # the norm is small, try use more times of iterations.
                        puts "> SmartAnalyze: setting more iteration times. To [dict get $control testIterTimesMore]."
                        test [dict get $control testType] [dict get $control testTol] [dict get $control testIterTimesMore] [dict get $control testPrintFlag]
                        # trial
                        set ok [analyze 1 $step]
                        incr counter
                        # Regardless converge or not, set the test times back.
                        puts "> SmartAnalyze: setting iteration times back. To [dict get $control testIterTimes]."
                        test [dict get $control testType] [dict get $control testTol] [dict get $control testIterTimes] [dict get $control testPrintFlag]
                        # judge whether converge
                        if { $ok == 0 } {
                            # converge, break.
                            set currentTime [expr $currentTime + $step]
                            break
                        }
                        # if not converge, just go on.
                    } else {
                        puts "> SmartAnalyze: the test norm [lindex $norm end] is way too large. "
                    }
                }
                # Then, try different algorithm types. Check tryAlterAlgoTypes
                if { [dict get $control tryAlterAlgoTypes] } {
                    foreach algoType [lrange [dict get $control algoTypes] 1 end] {
                        setAlgorithm $algoType
                        # trail
                        set ok [analyze 1 $step]
                        incr counter
                        # judge if converge
                        if { $ok == 0 } {
                            # converge, break the foreach loop
                            set currentTime [expr $currentTime + $step]
                            break
                        } else {
                            # not converge: try more times again.
                            set norm [testNorms]
                            if { [lindex $norm end] < [dict get $control normTol] } {
                                # the norm is small, try use more times of iterations.
                                puts "> SmartAnalyze: setting more iteration times. To [dict get $control testIterTimesMore]."
                                test [dict get $control testType] [dict get $control testTol] [dict get $control testIterTimesMore] [dict get $control testPrintFlag]
                                # trial
                                set ok [analyze 1 $step]
                                incr counter
                                # Regardless converge or not, set the test times back.
                                puts "> SmartAnalyze: setting iteration times back. To [dict get $control testIterTimes]."
                                test [dict get $control testType] [dict get $control testTol] [dict get $control testIterTimes] [dict get $control testPrintFlag]
                                # judge whether converge
                                if { $ok == 0 } {
                                    # converge, break the foreach loop.
                                    set currentTime [expr $currentTime + $step]
                                    break
                                }
                                # if not converge, just go on.
                            } else {
                                puts "> SmartAnalyze: the test norm [lindex $norm end] is way too large. "
                            }
                        }
                    }
                    # Here, the foreach loop is either broken or over. set algorithm back and then check if converge.
                    if { $ok == 0 } {
                        # converge, change the algorithm type order
                        set algoTypes [dict get $control algoTypes]
                        dict set control algoTypes [concat $algoType [lrange $algoTypes 0 [lsearch $algoTypes $algoType]-1] [lrange $algoTypes [lsearch $algoTypes $algoType]+1 end]]
                        puts "> SmartAnalyze: change algoType works. Change algoTypes to [dict get $control algoTypes]"
                        # break the loop. current time has already changed.
                        break
                    } else {
                        # if not converge, set algorithm back.
                        setAlgorithm [lindex [dict get $control algoTypes] 0]
                    }
                }
                # Next, try to shorten the step length.
                set step [expr $step * [dict get $control relaxation]]
                # judge the step length.
                if { $step < [dict get $control minStep] } {
                    # step is too small. try to force converge.
                    puts "!!! SmartAnalyze: The step length is smaller than the minimum step."
                    # check tryLooseTestTol
                    if { [dict get $control tryLooseTestTol] } {
                        # loose the test tolerance, and set step length back.
                        puts "> SmartAnalyze: setting the test tolerance to [dict get $control looseTestTolTo], use more iterate times directly. Step length back to [dict get $control initialStep]."
                        incr counterLooseTestTol
                        test [dict get $control testType] [dict get $control looseTestTolTo] [dict get $control testIterTimesMore] [dict get $control testPrintFlag]
                        set step [dict get $control initialStep]
                        # loop with step
                        while { $step >= [dict get $control minStep] } {
                            # trial
                            set ok [analyze 1 $step]
                            incr counter
                            # judge convergance
                            if { $ok == 0 } {
                                # converge, set test tolerance back. Break the while loop.
                                puts "> SmartAnalyze: test converged. setting test tolerance back to [dict get $control testTol]."
                                test [dict get $control testType] [dict get $control testTol] [dict get $control testIterTimes] [dict get $control testPrintFlag]
                                set currentTime [expr $currentTime + $step]
                                break
                            }
                            set step [expr $step * [dict get $control relaxation]]
                        }
                        # Here, the loop is whether over or broken. check convergance.
                        if { $ok == 0 } {
                            # converge, break the while True.
                            break
                        } 
                    }
                    # Next, try to force go on use Linear algorithm.
                    if { [dict get $control tryForceConverge] } {
                        puts "!!! SmartAnalyze: WARNING! FORCING CONVERGE using algorithm Linear at time $currentTime!"
                        incr counterForceConverge
                        algorithm Linear
                        # trial
                        set ok [analyze 1 $step]
                        incr counter
                        if { $ok == 0 } {
                            # Converge. (Should always converge.)
                            puts "Force converge successful. test norms are [testNorms]."
                            # set algorithm back.
                            setAlgorithm [lindex [dict get $control algoTypes] 0]
                            # set step length back
                            set step [dict get $control initialStep]
                            # set current time
                            set currentTime [expr $currentTime + $step]
                            # break the while True loop
                            break
                        } else {
                            # Abnormal situation. Return.
                            puts "Fail to Force converge. SmartAnalyze fail at time $currentTime."
                            return -1
                        }
                    }
                    # Don't try anything. Analyze fail.
                    puts ":( SmartAnalyze: Analyze failed at time $currentTime. Time usage: [expr ([clock clicks -millisec]-$startTime) / 1000.] seconds."
                    return -3
                } else {
                    puts "> SmartAnalyze: fail to converge, setting time step to $step."
                    # trial in a shortened step.
                    set ok [analyze 1 $step]
                    incr counter
                    if { $ok == 0 } {
                        # converge, set step back, break this while True
                        set currentTime [expr $currentTime + $step]
                        set step [dict get $control initialStep]
                        break
                    }
                }
            }
        }
    }
    if {[expr $counterForceConverge + $counterLooseTestTol] == 0} {
        puts ":D SmartAnalyze: finished successfully without forcing to converge. Time usage: [expr ([clock clicks -millisec]-$startTime) / 1000.] seconds."
        return 0
    } else {
        puts ":) SmartAnalyze: finished successfully. Time usage: [expr ([clock clicks -millisec]-$startTime) / 1000.] seconds."
        puts "WARNING: the test tolerance was loosen to [dict get $control looseTestTolTo] for $counterLooseTestTol time(s); Linear algorithm was used to force converge for $counterForceConverge time(s)." 
        return -1
    }
}


proc SmartAnalyzeStatic { node dof maxStep targets {controlDict {}}} {
    if {$controlDict != {}} {
        upvar $controlDict control
        puts "User defined control parameters"
        puts $control
    } else {
        puts "Using default control parameters"
        set control {}
    }
    #################################################
    #####      PARAMETERS RELATED TO TEST       #####
    #################################################
    # testType: string. Identical to the testType in OpenSees test command. Default is "EnergyIncr".
    #     Choices see http://opensees.berkeley.edu/wiki/index.php/Test_Command.
    if { ! [dict exists $control testType] } {
        dict append control testType "EnergyIncr"
    }
    # testTol: float. The initial test tolerance set to the OpenSees test command. Default is 1.0e-6.
    #          If tryLooseTestTol is set to True, the test tolerance can be loosen.
    if { ! [dict exists $control testTol] } {
        dict append control testTol 1.0e-6
    }
    # testIterTimes: integer. The initial number of test iteration times. Default is 7.
    #                If tryAddTestTimes is set to True, the number of test times can be enlarged.
    if { ! [dict exists $control testIterTimes] } {
        dict append control testIterTimes 7
    }
    # testPrintFlag: integer. The test print flag in OpenSees Test command. Default is 0.
    #     Choices see http://opensees.berkeley.edu/wiki/index.php/Test_Command.
    if { ! [dict exists $control testPrintFlag] } {
        dict append control testPrintFlag 0
    }
    # tryAddTestTimes: Boolean. Default is True If this is set to True, 
    #                  the number of test times will be enlarged if the last test norm is not too large depending on `normTol`,
    #                  the enlarged number is specified in `testIterTimesMore`.
    #                  Otherwise, the number of test times will always be equal to `testIterTimes`.
    if { ! [dict exists $control tryAddTestTimes] } {
        dict append control tryAddTestTimes True
    }
    # normTol: Float. Only useful when tryAddTestTimes is True. Default is 1.0e3.
    #                 If unconvergance is encountered, the last norm of test will be compared to `normTol`.
    #                 If the norm is smaller, the number of test times will be enlarged.
    if { ! [dict exists $control normTol] } {
        dict append control normTol 1.0e3
    }
    # testIterTimesMore: Integer. Only useful when tryaddTestTimes is True. Default is 50.
    #                    If unconvergance is encountered and norm is not too large, the number of test times will be set to this number.
    if { ! [dict exists $control testIterTimesMore] } {
        if { [dict get $control tryAddTestTimes] } {
            dict append control testIterTimesMore 50
        } else {
            dict append control testIterTimesMore [dict get $control testIterTimes]
        }
    }
    # tryLooseTestTol: Boolean. If this is set to True, if the unconvergance is encountered at minimum step,
    #                  the test tolerance will be loosen to the number specified by `looseTestTolTo`.
    #                  the step will be set back.
    #                  Default is True.
    if { ! [dict exists $control tryLooseTestTol] } {
        dict append control tryLooseTestTol True
    }
    # looseTestTolTo: Float. Only useful if tryLooseTestTol is True.
    #                 If unconvergance is encountered at the min step, the test tolerance will be set to this value.
    #                 Default is 1.
    if { ! [dict exists $control looseTestTolTo] } {
        dict append control looseTestTolTo 1.
    }
    #################################################
    #####    PARAMETERS RELATED TO ALGORITHM    #####
    #################################################
    # tryAlterAlgoTypes: Boolean. Default is False.
    #                    If it is set to True, different algorithm types specified in `algoTypes` will be tried during unconvergance.
    #                    If it is set to False, the first algorithm type specified in `algoTypes` will be used.
    if { ! [dict exists $control tryAlterAlgoTypes] } {
        dict append control tryAlterAlgoTypes False
    }
    # algoTypes: list of integer. A list of flags of the algorithms to be used during unconvergance.
    #            Only useful when tryAlterAlgoTypes is True. 
    #            The first flag will be used by default. If algorithm command was called in the model, it will be ignored.
    #            Default is { 40 }
    #            If you need other algorithm, try to add a new flag to the `setAlgorithm` procedure at the bottom.
    #            References:
    #             0:  Linear
    #             1:  Linear -initial
    #             2:  Linear -factorOnce
    #            10:  Newton
    #            11:  Newton -initial
    #            12:  Newton -initialThenCurrent
    #            20:  NewtonLineSearch
    #            21:  NewtonLineSearch -type Bisection
    #            22:  NewtonLineSearch -type Secant
    #            23:  NewtonLineSearch -type RegulaFalsi
    #            30:  ModifiedNewton
    #            31:  ModifiedNewton -initial
    #            40:  KrylovNewton
    #            41:  KrylovNewton -iterate initial
    #            42:  KrylovNewton -increment initial
    #            43:  KrylovNewton -iterate initial -increment initial
    #            44:  KrylovNewton -maxDim 6
    #            50:  SecantNewton
    #            51:  SecantNewton -iterate initial
    #            52:  SecantNewton -increment initial 
    #            53:  SecantNewton -iterate initial -increment initial
    #            60:  BFGS
    #            70:  Broyden
    #            80:  User-defined. Try to add your algorithm to the procedure `setAlgorithm`.
    if { ! [dict exists $control algoTypes] } {
        dict append control algoTypes { 40 20 }
    }
    # tryForceConverge: Boolean. Default is True.
    #                   If True, the last step during unconvergance will be setting algorithm to Linear.
    #                   Then the step will surely converge. However, the result may be bad.
    if { ! [dict exists $control tryForceConverge] } {
        dict append control tryForceConverge True
    }
    #################################################
    #####   PARAMETERS RELATED TO STEP LENGTH   #####
    #################################################
    # initialStep: Float. Default is equal to $dt.
    #              Specifying the initial Step length to conduct analysis.
    if { ! [dict exists $control initialStep] } {
        dict append control initialStep $maxStep
    }
    # relaxation: Float, between 0 and 1. Default is 0.5.
    #                   A factor that is multiplied by each time the step length is shortened.
    if { ! [dict exists $control relaxation] } {
        dict append control relaxation 0.5
    }
    # minStep: Float. Default is 1.0e-6.
    #          The step tolerance when shortening the step length.
    #          If step length is smaller than minStep, special ways to converge the model will be used according to `try-` flags.
    if { ! [dict exists $control minStep] } {
        dict append control minStep 1.0e-6
    }
    #################################################
    #####   PARAMETERS RELATED TO LOGGING       #####
    #################################################
    # printPer: integer. Print to the console every several trials. Default is 1.
    if { ! [dict exists $control printPer] } {
        dict append control printPer 10
    }
    #################################################
    #####                MAIN                   #####
    #################################################
    puts "Smart Analyze control parameters"
    puts $control
    # set counter on loose test tolerance
    set counterLooseTestTol 0
    # set counter on force converge
    set counterForceConverge 0
    # set initial algorithm
    setAlgorithm [lindex [dict get $control algoTypes] 0]
    # set initial test
    test [dict get $control testType] [dict get $control testTol] [dict get $control testIterTimes] [dict get $control testPrintFlag]
    # set initial step length.
    set step [dict get $control initialStep]
    # initialize displacement cursor
    set currentDisp 0
    # initialize converge flag
    set ok 0
    # initialize analyze times counter
    set counter 0
    # initialize current section
    set currentSection 0
    # initialize current distance
    set currentDistance 0
    # initialize the target disp 
    set targetDisp [lindex $targets $currentSection]
    # calculate the total distance and the disps for each section
    set distance [expr abs([lindex $targets 0])]
    set disps [lindex $targets 0]
    for { set i 1 } { $i < [llength $targets] } { incr i } {
        set distance [expr $distance + abs([lindex $targets $i] - [lindex $targets $i-1])]
        lappend disps [expr [lindex $targets $i] - [lindex $targets $i-1]]
    }
    # store the start time.
    set startTime [clock clicks -millisec]
    # Loop within the distance
    while { $ok == 0 && $currentDistance < $distance } {
        if { $counter >= [dict get $control printPer]} {
            # Console output
            puts "* SmartAnalyze:  [format %.4f [expr $currentDistance / $distance * 100]]% Finished. Disp for current section: [format %.4f $currentDisp]. Time passed: [expr ([clock clicks -millisec]-$startTime) / 1000.] seconds."
            # setting counter back.
            set counter 0
        }
        # Setting step
        if { [lindex $disps $currentSection] > 0 } {
            # going up 
            set step $maxStep
            if { $currentDisp >= [lindex $disps $currentSection] } {
                # reached section disp target
                set currentDisp 0
                incr currentSection
                if { $currentSection > [expr [llength $targets] - 1] } {
                    break
                }
                if { [lindex $disps $currentSection] > 0 } {
                    # still going up
                    set step $maxStep
                } else {
                    # going down
                    set step [expr -$maxStep]
                }
                puts "> SmartAnalyze: current section finished. Moving to a new section, disp target=[lindex $targets $currentSection], disp to go=[lindex $disps $currentSection]"
            } elseif { [expr $currentDisp + $step ] > [lindex $disps $currentSection] } {
                # The last step of this section
                set step [expr [lindex $disps $currentSection] - $currentDisp]
            } else {
                # normal step
                set step $maxStep
            }
        } else {
            # Going down
            set step [expr -$maxStep]
            if { $currentDisp <= [lindex $disps $currentSection] } {
                # reached section disp target
                set currentDisp 0
                incr currentSection
                if { $currentSection > [expr [llength $targets] - 1] } {
                    break
                }
                if { [lindex $disps $currentSection] > 0 } {
                    # going up
                    set step $maxStep
                } else {
                    # going down
                    set step [expr -$maxStep]
                }
                puts "> SmartAnalyze: current section finished. Moving to a new section, disp target=[lindex $targets $currentSection], disp to go=[lindex $disps $currentSection]"
            } elseif { [expr $currentDisp + $step] < [lindex $disps $currentSection] } {
                # The last step of this section
                set step [expr [lindex $disps $currentSection] - $currentDisp]
            } else {
                # normal step
                set step [expr -$maxStep]
            }
        }
        # set integrator
        integrator DisplacementControl $node $dof $step
        # Try analyze once.
        set ok [analyze 1]
        incr counter
        # judge convergance.
        if { $ok == 0 } {
            # converge.
            set currentDisp [expr $currentDisp + $step]
            set currentDistance [expr $currentDistance + abs($step)]
        } else {
            # Loop. If converge, break the loop.
            while { True } {
                # First check tryAddTestTimes.
                if { [dict get $control tryAddTestTimes] } {
                    # compare the test norms.
                    set norm [testNorms]
                    if { [lindex $norm end] < [dict get $control normTol] } {
                        # the norm is small, try use more times of iterations.
                        puts "> SmartAnalyze: setting more iteration times. To [dict get $control testIterTimesMore]."
                        test [dict get $control testType] [dict get $control testTol] [dict get $control testIterTimesMore] [dict get $control testPrintFlag]
                        # trial
                        set ok [analyze 1]
                        incr counter
                        # Regardless converge or not, set the test times back.
                        puts "> SmartAnalyze: setting iteration times back. To [dict get $control testIterTimes]."
                        test [dict get $control testType] [dict get $control testTol] [dict get $control testIterTimes] [dict get $control testPrintFlag]
                        # judge whether converge
                        if { $ok == 0 } {
                            # converge, break.
                            set currentDisp [expr $currentDisp + $step]
                            set currentDistance [expr $currentDistance + abs($step)]
                            break
                        }
                        # if not converge, just go on.
                    } else {
                        puts "> SmartAnalyze: the test norm [lindex $norm end] is way too large. "
                    }
                }
                # Then, try different algorithm types. Check tryAlterAlgoTypes
                if { [dict get $control tryAlterAlgoTypes] } {
                    foreach algoType [lrange [dict get $control algoTypes] 1 end] {
                        setAlgorithm $algoType
                        # trail
                        set ok [analyze 1]
                        incr counter
                        # judge if converge
                        if { $ok == 0 } {
                            # converge, break the foreach loop
                            set currentDisp [expr $currentDisp + $step]
                            set currentDistance [expr $currentDistance + abs($step)]
                            break
                        } else {
                            # not converge: try more times again.
                            set norm [testNorms]
                            if { [lindex $norm end] < [dict get $control normTol] } {
                                # the norm is small, try use more times of iterations.
                                puts "> SmartAnalyze: setting more iteration times. To [dict get $control testIterTimesMore]."
                                test [dict get $control testType] [dict get $control testTol] [dict get $control testIterTimesMore] [dict get $control testPrintFlag]
                                # trial
                                set ok [analyze 1]
                                incr counter
                                # Regardless converge or not, set the test times back.
                                puts "> SmartAnalyze: setting iteration times back. To [dict get $control testIterTimes]."
                                test [dict get $control testType] [dict get $control testTol] [dict get $control testIterTimes] [dict get $control testPrintFlag]
                                # judge whether converge
                                if { $ok == 0 } {
                                    # converge, break the foreach loop.
                                    set currentDisp [expr $currentDisp + $step]
                                    set currentDistance [expr $currentDistance + abs($step)]
                                    break
                                }
                                # if not converge, just go on.
                            } else {
                                puts "> SmartAnalyze: the test norm [lindex $norm end] is way too large. "
                            }
                        }
                    }
                    # Here, the foreach loop is either broken or over. check if converge.
                    if { $ok == 0 } {
                        # converge, change the algorithm type order
                        set algoTypes [dict get $control algoTypes]
                        dict set control algoTypes [concat $algoType [lrange $algoTypes 0 [lsearch $algoTypes $algoType]-1] [lrange $algoTypes [lsearch $algoTypes $algoType]+1 end]]
                        puts "> SmartAnalyze: change algoType works. Change algoTypes to [dict get $control algoTypes]"
                        # break the loop. current time has already changed.
                        break
                    } else {
                        # if not converge, set algorithm back.
                        setAlgorithm [lindex [dict get $control algoTypes] 0]
                    }
                }
                # Next, try to shorten the step length.
                set step [expr $step * [dict get $control relaxation]]
                # judge the step length.
                if { [expr abs($step)] < [dict get $control minStep] } {
                    # step is too small. try to force converge.
                    puts "!!! SmartAnalyze: The step length is smaller than the minimum step."
                    # check tryLooseTestTol
                    if { [dict get $control tryLooseTestTol] } {
                        # loose the test tolerance, and set step length back.
                        puts "> SmartAnalyze: setting the test tolerance to [dict get $control looseTestTolTo], use more iterate times directly. Step length back to [dict get $control initialStep]."
                        incr counterLooseTestTol
                        test [dict get $control testType] [dict get $control looseTestTolTo] [dict get $control testIterTimesMore] [dict get $control testPrintFlag]
                        set step [dict get $control initialStep]
                        # loop with step
                        while { $step >= [dict get $control minStep] } {
                            # trial
                            integrator DisplacementControl $node $dof $step
                            set ok [analyze 1]
                            incr counter
                            # judge convergance
                            if { $ok == 0 } {
                                # converge, set test tolerance back. Break the while loop.
                                puts "> SmartAnalyze: test converged. setting test tolerance back to [dict get $control testTol]."
                                test [dict get $control testType] [dict get $control testTol] [dict get $control testIterTimes] [dict get $control testPrintFlag]
                                set currentDisp [expr $currentDisp + $step]
                                set currentDistance [expr $currentDistance + abs($step)]
                                break
                            }
                            set step [expr $step * [dict get $control relaxation]]
                        }
                        # Here, the loop is whether over or broken. check convergance.
                        if { $ok == 0 } {
                            # converge, break the while True.
                            break
                        } 
                    }
                    # Next, try to force go on use Linear algorithm.
                    if { [dict get $control tryForceConverge] } {
                        puts "!!! SmartAnalyze: WARNING! FORCING CONVERGE using algorithm Linear at section=$currentSection disp=$currentDisp!"
                        incr counterForceConverge
                        algorithm Linear
                        # trial
                        integrator DisplacementControl $node $dof $step
                        set ok [analyze 1]
                        incr counter
                        if { $ok == 0 } {
                            # Converge. (Should always converge.)
                            puts "Force converge successful. test norms are [testNorms]."
                            # set algorithm back.
                            setAlgorithm [lindex [dict get $control algoTypes] 0]
                            # set step length back
                            set step [dict get $control initialStep]
                            # set currentTime
                            set currentDisp [expr $currentDisp + $step]
                            set currentDistance [expr $currentDistance + abs($step)]
                            # break the while True loop
                            break
                        } else {
                            # Abnormal situation. Return.
                            puts "Fail to Force converge. SmartAnalyze fail at section $currentSection disp $currentDisp."
                            return -1
                        }
                    }
                    # Don't try anything. Analyze fail.
                    puts ":( SmartAnalyze: Analyze failed at time $currentTime. Time usage: [expr ([clock clicks -millisec]-$startTime) / 1000.] seconds."
                    return -3
                } else {
                    puts "> SmartAnalyze: fail to converge, setting step length to $step."
                    # trial in a shortened step.
                    integrator DisplacementControl $node $dof $step
                    set ok [analyze 1]
                    incr counter
                    if { $ok == 0 } {
                        # converge, set step back, break this while True
                        set currentDisp [expr $currentDisp + $step]
                        set currentDistance [expr $currentDistance + abs($step)]
                        set step [dict get $control initialStep]
                        break
                    }
                }
            }
        }
    }
    if {[expr $counterForceConverge + $counterLooseTestTol] == 0} {
        puts ":D SmartAnalyze: finished successfully without forcing to converge. Time usage: [expr ([clock clicks -millisec]-$startTime) / 1000.] seconds."
        return 0
    } else {
        puts ":) SmartAnalyze: finished successfully. Time usage: [expr ([clock clicks -millisec]-$startTime) / 1000.] seconds."
        puts "WARNING: the test tolerance was loosen to [dict get $control looseTestTolTo] for $counterLooseTestTol time(s); Linear algorithm was used to force converge for $counterForceConverge time(s)." 
        return -1
    }
}



proc setAlgorithm { type } {
    switch $type {
        0  {
            puts "> SmartAnalyze: Setting algorithm to  Linear ..."
            algorithm Linear
        }
        1  {
            puts "> SmartAnalyze: Setting algorithm to  -initial ..."
            algorithm -initial
        }
        2  {
            puts "> SmartAnalyze: Setting algorithm to  -factorOnce ..."
            algorithm -factorOnce
        }
        10 {
            puts "> SmartAnalyze: Setting algorithm to  Newton ..."
            algorithm Newton
        }
        11 {
            puts "> SmartAnalyze: Setting algorithm to  Newton -initial ..."
            algorithm Newton -initial
        }
        12 {
            puts "> SmartAnalyze: Setting algorithm to  Newton -initialThenCurrent ..."
            algorithm Newton -initialThenCurrent
        }
        20 {
            puts "> SmartAnalyze: Setting algorithm to  NewtonLineSearch ..."
            algorithm NewtonLineSearch
        }
        21 {
            puts "> SmartAnalyze: Setting algorithm to  NewtonLineSearch -type Bisection ..."
            algorithm NewtonLineSearch -type Bisection
        }
        22 {
            puts "> SmartAnalyze: Setting algorithm to  NewtonLineSearch -type Secant ..."
            algorithm NewtonLineSearch -type Secant
        }
        23 {
            puts "> SmartAnalyze: Setting algorithm to  NewtonLineSearch -type RegulaFalsi ..."
            algorithm NewtonLineSearch -type RegulaFalsi
        }
        30 {
            puts "> SmartAnalyze: Setting algorithm to  Modified Newton ..."
            algorithm Modified Newton
        }
        31 {
            puts "> SmartAnalyze: Setting algorithm to  ModifiedNewton -initial ..."
            algorithm ModifiedNewton -initial
        }
        40 {
            puts "> SmartAnalyze: Setting algorithm to  KrylovNewton ..."
            algorithm KrylovNewton
        }
        41 {
            puts "> SmartAnalyze: Setting algorithm to  KrylovNewton -iterate initial ..."
            algorithm KrylovNewton -iterate initial
        }
        42 {
            puts "> SmartAnalyze: Setting algorithm to  KrylovNewton -increment initial ..."
            algorithm KrylovNewton -increment initial
        }
        43 {
            puts "> SmartAnalyze: Setting algorithm to  KrylovNewton -iterate initial -increment initial ..."
            algorithm KrylovNewton -iterate initial -increment initial
        }
        44 {
            puts "> SmartAnalyze: Setting algorithm to  KrylovNewton -maxDim 6"
            algorithm KrylovNewton -maxDim 6
        }
        50 {
            puts "> SmartAnalyze: Setting algorithm to  SecantNewton ..."
            algorithm SecantNewton
        }
        51 {
            puts "> SmartAnalyze: Setting algorithm to  SecantNewton -iterate initial ..."
            algorithm SecantNewton -iterate initial
        }
        52 {
            puts "> SmartAnalyze: Setting algorithm to  SecantNewton -increment initial  ..."
            algorithm SecantNewton -increment initial 
        }
        53 {
            puts "> SmartAnalyze: Setting algorithm to  SecantNewton -iterate initial -increment initial ..."
            algorithm SecantNewton -iterate initial -increment initial
        }
        60 {
            puts "> SmartAnalyze: Setting algorithm to  BFGS ..."
            algorithm BFGS
        }
        70 {
            puts "> SmartAnalyze: Setting algorithm to  Broyden ..."
            algorithm Broyden
        }
        80 {
            puts "> SmartAnalyze: Using user defined algorithm."
            # TODO: Please specify your algorithm here.
        }
        default {
            puts "!!! SmartAnalyze: ERROR! WRONG Algorithm Type!"
        }
    }
}