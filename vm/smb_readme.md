## PART 1: Set Up the Virtual Network (Isolated)

### 1. Open Virt-Manager

* Run:

  ```bash
  virt-manager
  ```

### 2. Create an Isolated Network

1. Click **Edit** → **Connection Details**.
2. Go to **"Virtual Networks"** tab.
3. Click **"+" (Add)** to create a new network.
4. Name it something like: `isolatednet`
5. Select:

   * **Forwarding method**: **Isolated network**
   * **IP address**: `192.168.200.1`
   * **Netmask**: `255.255.255.0` (default)
6. Click **Finish**, then click **Apply** to activate it.

This creates `virbr1` on your host.

### 3. Attach the Network to Your VM

1. Right-click your **Windows 11 VM** → **Open**.
2. Click the **"Show virtual hardware details"** icon.
3. Under **NIC (Network Interface)**:

   * Click **Add Hardware** → **Network**.
   * Select **"Isolated network: isolatednet (virbr1)"**.
   * Click **Finish**.
4. Now, your VM should have **2 interfaces**:

   * One for NAT (internet access)
   * One for **isolated file sharing**

---

## PART 2: Set Up the Shared Folder on Host

### 1. Create Shared Directory

Open terminal:

```bash
mkdir -p ~/vm/shared
```

### 2. Create a Group for Sharing

```bash
sudo groupadd sambashare
```

### 3. Add Your User to the Group

```bash
sudo usermod -aG sambashare $USER
```

**Log out and log back in** so the group membership takes effect.

### 4. Set Permissions on the Folder

```bash
sudo chown root:sambashare ~/vm/shared
sudo chmod 2775 ~/vm/shared
```

This lets anyone in `sambashare` read/write the folder.

---

## PART 3: Configure Samba on Host

### 1. Install Samba

```bash
sudo pacman -S samba
```

### 2. Create a Samba Config File

Edit `/etc/samba/smb.conf`:

```bash
sudo nano /etc/samba/smb.conf
```

Paste the following:

```ini
[global]
   workgroup = WORKGROUP
   server string = Arch Samba Server
   netbios name = archhost
   security = user
   map to guest = never
   interfaces = lo virbr1
   bind interfaces only = yes

[Shared]
   path = /home/yourusername/vm/shared
   valid users = @sambashare
   force group = sambashare
   create mask = 0660
   directory mask = 2770
   writable = yes
   browsable = yes
```

Replace `/home/yourusername/vm/shared` with your actual path.

### 3. Set Up a Samba User

Add your Linux user to Samba:

```bash
sudo smbpasswd -a $USER
```

Enter a password — you'll use this from Windows.

### 4. Enable and Start Samba Services

```bash
sudo systemctl enable --now smb nmb
```

---

## PART 4: (Optional) Allow Samba on virbr1 in Firewall

If you're using `iptables`, allow SMB on the isolated interface:

```bash
sudo iptables -A INPUT -i virbr1 -p tcp -m multiport --dports 137,138,139,445 -j ACCEPT
```

---

## PART 5: Connect from Windows 11 VM

### 1. Start the Windows 11 VM

### 2. Find IP of Linux Host

In Windows CMD (inside VM):

```cmd
ipconfig
```

Look at the interface that connects to `192.168.200.x`. If your VM is `192.168.200.10`, your host is probably `192.168.200.1`.

Try pinging from Windows:

```cmd
ping 192.168.200.1
```

Should respond.

### 3. Access the Share

In **File Explorer**:

* Go to the address bar and type:

```text
\\192.168.200.1\Shared
```

* When prompted for credentials:

  * **Username**: your Linux username
  * **Password**: the Samba password you set

Check "Remember credentials" if you want auto-login.

You should now see and access your shared folder!
