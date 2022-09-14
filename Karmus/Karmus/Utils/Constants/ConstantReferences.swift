//
//  ConstantReferences.swift
//  Karmus
//
//  Created by User on 8/17/22.
//

import Foundation

public struct References {
    
    static let fromMainToIdentificationScreen = "toIdentificationScreen"
    static let fromMainToRegistrationScreen = "toRegistrationScreen"
    static let fromIdentificationScreenToAccountScreen = "toAccountScreen"
    static let fromIdentificationToRegistrationScreen = "toRegistrationScreen2"
    
    static let fromAccountScreenToMainStoryboard = "toMainStoryboard"
    static let fromMapToTasksScreen = "toTasksScreen"
    static let fromMapToActiveTasksScreen = "toActiveTasksScreen"
    static let fromMapToCreationTaskScreen = "toCreationTaskScreen"
    static let fromMapToComplitedTasksScreen = "toComplitedTasksScreen"
    
    static let fromMapActiveTaskToDeclarationTaskScreen = "toDeclarationScreen"
    static let fromMapTaskToConditionTaskScreen = "toConditionTaskScreen"
    
    static let fromActiveTasksToDeclarationOfTasksScreen = "toDeclataionOfTasksScreen"
    static let fromDeclarationToMapScreen = "toMapScreen"
    static let fromCreationToTaskMapScreen = "toTaskMapScreen"
    
    static let fromTasksToConditionTaskScreen = "toConditionTaskScreen"
   
    static let fromConditionTaskToMapScreen = "toMapScreen"
    static let fromConditionTaskToTasksScreen =  "toTasksScreen"
    static let ftomTaskMapToMapScreen = "toMapScreen"
    static let fromComplitedTasksToProcessingTaskScreen = "toProcessingTaskScreen"
    static let fromConditionTaskToAccountScreen =  "toAccountScreen"
    static let fromDeclarationToActiveTasksScreen = "ToActiveTasksScreen"
    
    
    static let fromDeclarationToTasksScreen = "toTasksScreen"
    static let fromIdentificationScreenToNewUserScreen = "toNewUserScreen"
    static let fromNewUserScreentoFillMainInfo = "toFillMainProfileInfo"
    static let fromFillMainInfotoFillAdditionalInfo = "toFillAdditionalInfo"
    static let fromFillAdditionalInfotoAccountScreen = "toAccountScreenSecond"

}
