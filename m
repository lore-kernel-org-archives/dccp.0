From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 01 Dec 2006 13:40:07 +0000
Subject: Re: [PATCHv2] [DCCP]: Use higher timeout value for nofeedback timer
Message-Id: <200612011340.08494@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612011314.26835@strip-the-willow>
In-Reply-To: <200612011314.26835@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Arnaldo Carvalho de Melo:
|  We're agreeing Gerrit... you jumped to conclusions too fast because
|  you didn't read what I said in the next paragraph, that I quote here:
|  
|  ------------------------
|  Clarification on this one, you had _fixed_ it in your previous patch,
|  then removed this bit :)
|  ------------------------
Oh, I apologise. 

I just got an email from Colin Perkins (do you read dccp@ietf?) who says
that it should be 16..20msec. I think will change to milliseconds, use the
default of 100msec suggested by Mark Handley, and update the configuration 
menu once again.

Gerrit
