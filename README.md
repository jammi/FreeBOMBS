
*FreeBOMBS is a Free Bill of Materials Build System*


# Introduction

The goal of FreeBOMBS is to provide a precise system for configuring product BOM's as well as
an online user interface for end users to configure their product and get a full BOM as the result.

Further development will include an editor for the YAML databases (and support other structure formats).


# Databases

FreeBOMBS uses a database consisting of the following YAML files in a folder.
There is an example database included in the dbs directory "dbs/freeems-puma-spin1"

- Mandatory keys are in **bold**
- Markdown is allowed (but not supported yet) in at least ``title`` and ``description`` fields.


## The component type specification document: component_types.yaml

This is a definition list of component types (not implemented yet).
It will include further, dynamic validation rules for component data and UI layout.


## The supplier specification document: suppliers.yaml

A list of known/supported component suppliers. Each key on the top level is the supplier ID.
Any unique string is allowed. Each value MUST be a Hash containing the following items:

- **title**: Human (user) -readable string; the full name of the supplier.
- **homepage**: The home-page URL of the supplier.
- **currency**: The default currency used by the supplier, only ``USD`` and ``EUR`` supported currently.


## The component specification document: components.yaml

A database of all components used in the project.
Each key on the top level is the manufacturer ID code of the component. These MUST be unique.
If the ID is shared amongst several vendors or is otherwise generic, suffix the ID with a unique identifier.
The part number in the supplier section of the component defines which exact component to use.
There MUST be a Hash for each key. What's defined below is the contents of each key.


### Structure of an obsolete component

Mark a component as absolete, when it becomes hard to source or is replaced by something better.
You should define a replacement component instead and make a link to it using the replacement component reference ID.

- **title**: A single-line description of the component
- **obsolete**: MUST be true
- replacement: A reference ID to an equivalent part, which MUST be defined in the components database

Any items of a normal component are allowed, but not required.


### Structure of a normal component
- **title**: A single-line description of the component
- **description**: A multi-line description of the component. Optional, if a datasheet URL is defined.
- **datasheet**: An URL to the datasheet of the component. Optional, if the description is defined.
- **suppliers**: A Hash containing supplier ID's as keys and the following items as the value (Hash):
  - **part**: The part number of the supplier as a String.
  - **price**: The price as a number, eg. ``0.053`` or ``18.84`` or ``37``. Use the default currency of the supplier, it will be normalized.

Currently, any extra key-value pairs are allowed, but not supported. Support will be added,
when component_types.yaml is defined.

Examples:
<pre>
'MCR10EZPF1001':
  title: Compact Thick Film Chip Resistor
  datasheet: http://www.rohm.com/products/databook/r/pdf/mcr10.pdf
  suppliers:
    digikey:
      part: 'RHM1.00KCRDKR-ND'
      price: 0.042
'AU-Y1002-A-R':
  title: USB A-B Male cable
  category: cables
  description: |
    This is a regular USB A to B cable, you might already have one
    for your printer or a miscellaneous similar device. Choose
    something that works with your USB receptacle.
  suppliers:
    digikey:
      part: 'AE9931-ND'
      price: 5.75
'CD74HCT86M96':
  title: 74HC series logic gate
  vender: Texas Instruments
  category: IC
  mounting: SMD
  voltage: [ 4.5, 5.5 ] # V; range
  current: 0.0052 # 5.2mA
  temperature: [ -55, 125 ]
  datasheet: http://focus.ti.com/lit/ds/symlink/cd74hc86.pdf
  suppliers:
    digikey:
      part: '296-8201-1-ND'
      price: 0.7
'52000001009':
  title: Fuse Clip (not included)
  obsolete: true
'74HC86DR2G':
  title: 74HC series logic gate **OBSOLETE**
  obsolete: true
  replacement: 'CD74HCT86M96'
</pre>


## The product configuration specification document: configurations.yaml

A structure defining, which components are used in which configuration.


### Component references:
Component references are defined as an Array containing the amount and component ID of the component used.
1. Amount of the component (number)
2. Component ID of the component (string)

Example: ``[ 4, 'RMCF0805JT1K60' ]``


#### Alternative syntax:
When only one compnent is needed, the Array pair containing the amount may be omitted, just supply the component ID as a string instead.

Example: ``'RMCF0805JT1K60'``


### Top-level structure (the project itself)
- **title**: A single-line string defining the name of the project.
- **description**: A multi-line string defining the purpose and general info about the project.
- **components**: A list of baseline components as an Array, see "Component references". These are always included in the BOM.
- **sections**: A list of section definitions (see below; "Section structure".
- **section_order**: A list of section ID's defining in which order to present the sections to the user.


### Section structure
- **title**: A single-line string defining the name of the project.
- **description**: A multi-line string defining the purpose and general info about the project.
- **value**: The default amount of component sets of in this section to include in the BOM.
- **min**: The minimum value.
- **max**: The maximum value.
- checked: Whether to enable the section by default or not. Allowed values: true or false
- presets: A list of pre-set values with titles. An array containing Hash structures defined as:
  - **title**: The title of the preset, should be descriptive.
  - **value**: The value preset to apply, if selected. Can't be greater than max or less than min.
- excludes: A section ID defining a single other section to uncheck, if checked. Can also be defined as a list of section ID's to uncheck, when checked.
- components: A list of baseline components as an Array, see "Component references".
  - The amounts are multiplied by the value entered.
  - Obsolete component references with a replacement defined show a warning.
  - Obsolete compnonet references without a replacement are treated as errors.

Example:
<pre>

title: FreeEMS Puma Spin 1
description: |
  # Introduction
  This BOM is highly experimental, proceed at your own risk!
  The baseline configuration includes only a set of bare minimum parts.
components:
  - 'MCR10EZPF1001'
  - 'RSF200JB-1R0'
  - '52000001009'
  - [ 11, 'RMCF0805FT10K0' ]
  - [ 2, 'RMCF0805JT10M0' ]
  - 'RMCF0805JT22K0'
  - 'MCR10EZPF3902'
  - [ 12, 'GRM21BR71H104KA01L' ]
  - [ 9, 'RMCF0805JT1K60' ]
  - [ 2, 'UVZ1C100MDD' ]
  - [ 2, '500R15N220JV4T' ]
  - 'MC9S12XDP512MAL'
section_order:
  - RECOMMENDED
  - INJ-H
  - INJ-L
  - IGN
sections:
  RECOMMENDED:
    title: Recommended baseline parts
    description: |
      Don't uncheck this, unless you know what you are doing!
    checked: true
    value: 1
    min: 0
    max: 1
    components:
      - 'UDQ2916LBTR-T'
      - [ 4, 'MCR10EZPF1001' ]
      - [ 2, 'RSF200JB-1R0' ]
      - [ 4, 'GRM21BR71H104KA01L' ]
      - [ 4, 'RMCF0805JT1K60' ]
      - 74HC86DR2G
  INJ-H:
    title: High-Z injector circuit configuration
    description: |
      Enter the number of injector drivers you want to use.
    presets:
      - title: "1-cylinder engine"
        value: 1
      - title: "4-cylinder engine, semi-sequential injection"
        value: 2
      - title: "4-cylinder engine, sequential injection"
        value: 4
    checked: true
    excludes: INJ-L
    value: 0
    min: 0
    max: 8
    components:
      - 'VNP20N07'
  INJ-L:
    title: Low-Z injector circuit configuration
    description: |
      Enter the number of injector drivers you want to use.
    presets:
      - title: "High-Z injector system or ignition only"
        value: 0
      - title: "1-cylinder engine"
        value: 1
      - title: "4-cylinder engine, semi-sequential injection"
        value: 2
      - title: "4-cylinder engine, sequential injection"
        value: 4
    checked: false
    excludes: INJ-H
    value: 0
    min: 0
    max: 8
    components:
      - 'RMCF0805JT1K60'
      - 'MCR10EZPF3901'
      - 'GRM216R71H103KA01D'
      - 'WHCR10FET'
      - '2N6045G'
      - '1N5364BRLG'
      - 'LM1949N/NOPB'
  IGN:
    title: Ignition circuit configuration
    description: |
      Enter the number of ignition drivers you want to use.
    presets:
      - title: "Fuel-only"
        value: 0
      - title: "Distributor or single-cylinder engine"
        value: 1
      - title: "Sequential for 2-cylinder engines"
        value: 2
      - title: "Wasted spark for 4-cylinder engines"
        value: 2
    checked: false
    value: 0
    min: 0
    max: 4
    components:
      - 'MCR10EZPF1001'
      - 'RMCF0805FT10K0'
      - 'RMCF0805JT1K60'
      - 'LH R974-LP-1-0-20-R18'
      - 'VNP20N07'
</pre>

## Validating the database:

### You'll need the following dependencies installed:

- Ruby
- RubyGems (if Ruby version is below 1.9)
- ``gem install yaml`` (if Ruby version is below 1.9)
- ``gem install bluecloth`` (used for the Markdown to html conversion)
- ``gem install highline`` (used for the CLI)
 

### Run the valitation script like this:

``ruby test/check_db_sanity.rb``

The script outputs a verbose state of what it's checking, warnings are indented with two dots and errors halt execution after displaying the error message.


# References:
- [YAML](http://www.yaml.org/)
- [Ruby](http://www.ruby-lang.org/)
- [RubyGems](http://www.rubygems.org/)
- [Official FreeBOMBS repository](https://github.com/jammi/FreeBOMBS)


# Credits
- FreeBOMBS: Juha-Jarmo Heinonen
- The various [FreeEMS](http://www.freeems.org/) contributors for all the input as well as a baseline configuration.

