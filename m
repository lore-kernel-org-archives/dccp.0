From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 05 Dec 2007 13:34:49 +0000
Subject: Re: [PATCH 7/7] [TFRC] New rx history code
Message-Id: <20071205133449.GB893@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1196631416-17778-8-git-send-email-acme@redhat.com>
In-Reply-To: <1196631416-17778-8-git-send-email-acme@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > In the end this went back to the same questions and issues that were tackled between
| > February and March this year. I wish we could have had this dicussion then; it would
| > have made this email unnecessary.
| 
| That is why it is important that the changeset comment collects these
| scattered notes and discussions. Think about in some years from now we
| will be left with a situation where we would have to look at many places
| to understando some aspects of what is in the code. While this happens
| and we have google for that I think that since you keep such detailed
| notes it is not a problem to get them in the changesets.
|  
I agree, the changelogs are all a bit short. When condensing from 40 to 16 patches the changelogs
were also cut down, for fear of being too verbose. Will go through the patches in the next days and
see if/where this can be improved, that would probably have saved some trouble.

| >  * But where I need to interact is when changes are made to the algorithm, even if these may 
| >    seem small. The underlying reasons that lead to the code may not be immediately clear,
| >    but since this is a solution for a specific problem, there are also specific reasons; which
| >    is why for algorithm changes (and underlying data structure) I'd ask you to discuss this first
| >    before committing the patch. 
| 
| I did this for the RX handling, where changes were made. Did that for
| the TX but ended up commiting before comments from you, but I think its
| fair to say that the changes for the TX history were more organizational
| than in the essence of the algorithm.
|  
It was a similar situation: the RFC patch came out on Thursday afternoon; I replied a bit hurriedly
on Friday that it seemed ok, but found the full confirmation only on Sunday after putting all
recent changes into the test tree. And yes, you made a good job of it.
