## Test environments

* Local OS X (14.2,Apple M1 Max) install, R 4.1.1
* Ubuntu Linux 20.04.1 LTS (on R-hub and local), R 4.1.2
* Fedora Linux (on R-hub) R-devel
* Debian Linux (on R-hub) R-devel
* Local Windows (10 pro)
* Windows Server 2022, R-devel

## R CMD check results

No ERRORs or WARNINGs. 

There are 5 NOTEs.

1. This is a new submission

2. In Windows.The note might be related to an issue in `rhub` see 
https://github.com/r-hub/rhub/issues/560

```
checking for non-standard things in the check directory ... NOTE
  Found the following files/directories:
    ''NULL''
```

3. In Windows (Server 2022, R-devel 64-bit). In [R-hub issue #503](https://github.com/r-hub/rhub/issues/503) mention that this could be due 
to a bug/crash in MiKTeX and can likely be ignored.

```
* checking for detritus in the temp directory ... NOTE
Found the following files/directories:
  'lastMiKTeXException'
```


4. In Fedora and Ubuntu Linux [R-hub issue #548](https://github.com/r-hub/rhub/issues/548).
   The issue seems to be an Rhub issue and so can likely be ignored. 
```
* checking HTML version of manual ... NOTE
Skipping checking HTML validation: no command 'tidy' found
```

5. Ubuntu and Fedora, examples with CPU (user + system) or elapsed time > 5s.


Best regards,

Luis Osorio-Olvera
