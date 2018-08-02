# OpenComputers
Collection of OpenComputers programs for Minecraft

GitHub https://github.com/mc-oc

Website http://www.minecraftopencraft.com

## Programs
* `remote-light-controller`
  * Remote Light Controller Network Service.
* `remote-door-controller`
  * Remote Door Controller Network Service

## Raid Installation

#### Preparing Raid

Using a host machine that is connected to a raid device, has an internet card and the oppm package manager.

`oppm install gitrepo`

`mkdir /mnt/<raid>/`

`gitrepo mc-oc/OpenComputers /mnt/<raid>/`


#### Installing On Networked Device

On a networked host machine that can see the raid device. Perform the following.

`install`
 * This will ask you to install raid. (Yes)
 
 You may now access the programs from shell. 
 
 `man rd-service`
 
 `man rd-cli`
 
 `man light-service`
 
 `man light-cli`