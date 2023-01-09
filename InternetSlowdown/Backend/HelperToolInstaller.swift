//
//  HelperToolExtension.swift
//  InternetSlowdown
//
//  Created by Mateo Ochoa on 2022-12-07.
//

import Foundation
import ServiceManagement

extension HelperTool {
    static func installHelperTool() {
        // Check that the rights are written in the policy database
        let areRightsSetUp: Bool = Authorization.areRightsSetUp()
        if !areRightsSetUp {
            Authorization.setupAuthorizationWithErrors()
        }
        
        // Ensure that user has the rights to install the privileged helper tool
        let hasRights = Authorization.userHasRightToInstallPrivilegedTool()
        
        guard (hasRights == errAuthorizationSuccess) else {
            let error: CFString = SecCopyErrorMessageString(hasRights, nil)!
            ISLogger.warning(with_message: "User is not authorized to install privileged helper tool. Error: \(error)")
            return
        }
        
//        Uncomment when I have macOS 13 or newer installed, otherwise I cannot test whether the app works with this new API or not
//        if #available(macOS 13, *) {
//            do {
//                try SMAppService.daemon(plistName: "com.mochoaco.InternetSlowdownd.plist").register()
//            } catch {
//                ISLogger.errorError(with_message: "SMAppService could not register the helper tool due to the following error: ", error: error)
//            }
//        } else {
            var error: Unmanaged<CFError>?
            let installationStatus = SMJobBless(kSMDomainSystemLaunchd, "com.mochoaco.InternetSlowdownd" as CFString, Authorization.clientAuthRef!, &error)
            if !installationStatus {
                ISLogger.logger.error("SMJobBless failed to install helper tool with error: \(error!.takeUnretainedValue())")
            } else {
                ISLogger.logger.info("SMJobBless installed the helper tool successfully!")
            }
//        }
    }
}
