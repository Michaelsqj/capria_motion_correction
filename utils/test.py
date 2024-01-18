import numpy as np

a = np.random.rand(3, 4, 5)
troi=[0,2,4]
print(a[0:3,1:3,troi])
print(a[0:3,1:3,troi].shape)