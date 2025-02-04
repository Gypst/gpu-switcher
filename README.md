### Parameters

This script supports the following parameters to manage GPU devices via PowerShell. You can use these parameters for silent operations or configure the device name dynamically.

#### `-silenceEnable`

- **Description**: Enables the specified GPU device without showing the interactive menu.
- **Usage**: Use this parameter to enable the GPU silently. Or just run the `silenceEnable.ps1` file.
- **Example**:
  ```powershell
  .\gpu-switcher.ps1 -silenceEnable
  ```

#### `-silenceDisable`

- **Description**: Disables the specified GPU device without showing the interactive menu.
- **Usage**: Use this parameter to disable the GPU silently. Or just run the `silenceDisable.ps1` file.
- **Example**:
  ```powershell
  .\gpu-switcher.ps1 -silenceDisable
  ```

#### `-deviceName`

- **Description**: Specifies the friendly name of the device to manage. This allows you to target a specific GPU or another device by its name.
- **Default Value**: `*NVIDIA GeForce RTX 3070 Laptop GPU*`
- **Usage**: Use this parameter to specify a custom device name or pattern.
- **Example**:
  ```powershell
  .\gpu-switcher.ps1 -silenceDisable -=deviceName "*AMD Radeon RX 6800*"
  ```

---

### Example Usage

#### Silent Mode (Command-Line)

- Enable the GPU:
  ```powershell
  .\gpu-switcher.ps1 -silenceEnable
  ```
- Disable the GPU:
  ```powershell
  .\gpu-switcher.ps1 -silenceDisable
  ```
- Manage a different device:
  ```powershell
  .\gpu-switcher.ps1 -silenceDisable -deviceName "*Intel UHD Graphics*"
  ```

#### Interactive Menu

Run the script without any parameters to access the interactive menu:

```powershell
.\gpu-switcher.ps1
```

---

### Notes

- The script requires **Administrator privileges** to perform device management operations. If not run as Administrator, it will automatically restart with elevated permissions.
- Ensure the specified device name (`-deviceName`) matches the friendly name of the target device in the **Device Manager**.

---
