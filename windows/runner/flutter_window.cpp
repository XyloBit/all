#include "flutter_window.h"

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>
#include <flutter/method_call.h>
#include <flutter/standard_message_codec.h>

#include <windows.h>

#include "resource.h"

namespace {

    const std::string kChannelName = "flutter/file_picker";

    void FilePickerHandler(
            const flutter::MethodCall<flutter::EncodableValue>& call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        // Implement file picker logic here for Windows
    }

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project) {
    flutter_view_controller_ = std::make_unique<flutter::FlutterViewController>(
            project, GetDesktopWindow());
    flutter_view_controller_->SetOnMethodCallHandler(FilePickerHandler);
    flutter_view_controller_->Create();
}
