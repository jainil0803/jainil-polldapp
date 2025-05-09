# jainil-polldapp
features added:-
1)Poll Expiry Time: Option to set an expiry time for each poll.
Added expiryTime to the Poll struct
Updated createPoll function

2)Poll Deletion: Poll creators can delete their poll.
Smart Contract:
Added deletePoll function
Frontend:
Added a delete button for the poll creator to delete a poll.
Enabled the button only if the connected account is the creator of the poll.

3)Disable Vote Button After Voting: Users cannot vote twice on the same poll.
Frontend:
Added logic to check if the user has already voted by storing the user’s voting status.

4)Voting Percentage Bars: Visual representation of the voting results.

