#A2StoryboardSegueContext

`A2StoryboardSegueContext` allows you to supplement your segues' identifier strings with context objects.

##Usage

Specify a segue's context in the `UIViewController` category method `-performSegueWithIdentifier:sender:context:` and retrieve it through `UIStoryboard`'s `context` property.

##License

`A2StoryboardSegueContext` is licensed by [Alexsander Akers](http://alexsander.ca) and [Pandamonia LLC](http://pandamonia.us) under the Simplified BSD License, which is reproduced in its entirety here:

> Copyright (c) 2011, Alexsander Akers
> All rights reserved.
> 
> Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
> 
> - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
> - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
> 
> THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


