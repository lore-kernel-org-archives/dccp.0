From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 23 Nov 2006 09:46:59 +0000
Subject: Re: [PATCH 3/6]: Fix calculation of t_ipi time of scheduled transmission
Message-Id: <200611230946.59875@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00611210945l39bc33f5q3ab38c0bba022c1a@mail.gmail.com>
In-Reply-To: <5640c7e00611210945l39bc33f5q3ab38c0bba022c1a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  Gerrit - I was not trying to cast dispersions on you at all. I just
|  wanted some time to review it properly as I've spent a bit of time in
|  this code and would like to review CCID3 changes before they merge.
I understand this and this is the main reason why only send small, incremental patches; and
strive to give a justification for each step. In this way it is easier to verify whether the
changes actually improve the code or if they are not necessary. What I want to avoid is 
messing up someone else's code.

|  >   => Since these bits are so similar, I would actually suggest to accommodate them in
|  >       one function, since:
|  >                 --t_ipi changes only if one of `s' or X_calc changes
|  >                 --if `s' / X_calc remain unchanged after feedback, t_ipi remains as before
|  >                 --t_delta depends on t_ipi
|  >                 --the calculation of t_nom depends on t_ipi (as in the above snippets)
|  >
|  
|  Agree.
Since your last email I have spent some more time going through the standard documents; if you
agree then it may be good to update - will review and prepare patches for review.
