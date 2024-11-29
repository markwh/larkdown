from setuptools import setup, find_packages

setup(
    name='larkdown',
    version='0.1',
    packages=find_packages(),
    py_modules=['larkdown'],
    install_requires=[
        'langchain',
        'langchain-community',
    ],
    entry_points={
        'console_scripts': [
            'larkdown=larkdown.larkdown:main',
        ],
    },
    author="Mark Hagemann",
    author_email="mark.hagemann@gmail.com",
    description="A Python module for parsing larkdown and streaming messages.",
    url="https://github.com/markwh/larkdown",  # Example URL
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Intended Audience :: Developers',
        'Programming Language :: Python :: 3',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
    ],
    python_requires='>=3.6',
)
