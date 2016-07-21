# chuck

Music creation library in Python built on ChucK

See examples in examples folder, and documentation in https://github.com/Calysto/chuck/blob/master/docs/API.md

Currently requires that modern chuck server (e.g., 1.3.5.2) be installed and running. 

## Install

```python
pip install chuck -U
```

## Download

You need a chuck server for your OS.

You can download chuck from: http://chuck.stanford.edu/release/

## Running

Example command to start server:

chuck.alsa --verbose:9 --port:9000 chuck/osc/oscrecv.ck

In another terminal, you can then run any of the example Python scripts.

## References

This work is based on initial code by Ananya Misra. 

Related Papers:

* https://scholar.google.com/citations?user=ZCf3h5UAAAAJ&hl=en

especially:

https://scholar.google.com/citations?view_op=view_citation&hl=en&user=ZCf3h5UAAAAJ&citation_for_view=ZCf3h5UAAAAJ:W7OEmFMy1HYC
