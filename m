From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 01 Dec 2006 18:34:52 +0000
Subject: Re: [BUG] CCID3 performance is f**ked
Message-Id: <200612011834.52472@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00611301425v1c0c4b07kfeace18480cd0039@mail.gmail.com>
In-Reply-To: <5640c7e00611301425v1c0c4b07kfeace18480cd0039@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Ian - I have to agree, the performance at the moment is nothing to
boast about. I will be sticking my head into this until the code
works again to satisfaction. 
It would be most helpful if people could submit observations and bug
reports meanwhile. I will work full time on this next week.

|  My standard for submitting patches is that it still works at 
|  least as well as before. It's not good when users pull kernels and
|  they don't work.
Agree - you are right, I could have tested more. But there is so much to
be fixed that I postponed it at the moment - my queue of CCID 3 ToDos 
resembles more and more a stack.


|  bisect faulty kernel trees.
I am not sure that bisecting is the right method. It is good when everything
else fails. 

|  > Thank you for forwarding this onto the IETF list.
|  
|  I am not sure if this is sarcasm or not.
No sorry - it was meant to be humorous, not sarcastic. It has indeed proven
to be very helpful -- I have added the comments by Perkins/Handley to the menu.

You are right about what you are saying with regard to the testing. As per
the earlier email, I will work on this code until the performance is reasonable.
