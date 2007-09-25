From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 25 Sep 2007 08:52:57 +0000
Subject: Re: unchanged functions between ccid-3 and ccid-4
Message-Id: <200709250952.57753@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570709201928l270b24cdod359349ca3d3508@mail.gmail.com>
In-Reply-To: <5bc4c4570709201928l270b24cdod359349ca3d3508@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

 
|  > Anyway, I'm already identifying the candidate codes to be shared
|  > between ccid3 and ccid4 if you didn't this yet. Another option is wait
|  > for gerrit suggestion on this issue and discuss more about that and
|  > define a strategy to avoid code repetition.
|  
|  See? Wait for Gerrit, wait for Arnaldo, reach a consensus on code layout
|  first... nah, get something that works, when and if people send
|  suggestions you react, but don't get lack of feedback on these matters
|  to make you stop coding.
|  
I'll say the same - the repository is yours, just keep working on it until
you have soomething that works for you - when there are actual problems with
the CCID3 code, please however mail them to the list.

I just remembered a very crude, but technically correct hack: if you want
to avoid the work of linking, header dependencies, one can include entire
source files using the preprocessor macro, e.g. in ccid4.c:

#include "ccid3.c"	/* works as expected, all code is imported */

This allows small and clear code (only the `diff' needs to be added, but I think 
the mainline guys don't like it so much :)
