## SALSA: Shrunk Additive Least Squares Approximations
This is a Matlab implementation of SALSA, a method for high dimensional nonparametric
regression using additive approximations. For more details read our paper below.

### Installation & Getting Started
- Just add the salsa/ subdirectory to your Matlab workspace and you are ready to go.
- Using this library is fairly straightforward. To use with default hyper-parameters
  just run salsa(Xtr, Ytr) where Xtr,Ytr are the training data and labels.
- To modify hyper-parameters read salsa.m
- We have released 12 of the 16 datasets used in the paper. The other 4 datasets are
  not public.
- experiments/realDemo.m demonstrates how to use our method on the datasets.

### Citation
If you use this library in your academic work please cite our paper (pre-print)"
"Additive Approximations in High Dimensional Nonparametric Regression via the SALSA"
Kirthevasan Kandasamy, Yaoliang Yu.
The paper is available at http://www.cs.cmu.edu/~kkandasa/pubs/kandasamy15salsa.pdf.

### License
This software is released under GNU GPL v3(>=) License. Please read LICENSE.txt for
more information.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

"Copyright 2015 Kirthevasan Kandasamy"


- For questions/ bug reports please email kandasamy@cs.cmu.edu

