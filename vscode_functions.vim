function! s:fixVisualEndPos(startPos, endPos)
    "  Check if the cursor is at the beginning of the visual selection
    if (a:startPos[1] == a:endPos[1] && a:startPos[2] > a:endPos[2]) || a:startPos[1] > a:endPos[1]
			let a:startPos[2] = a:startPos[2] + 1
      return [a:endPos, a:startPos]
    endif
    let a:endPos[2] = a:endPos[2] + 1
    return [a:startPos, a:endPos]
endfunction

function! VSCodeNotifyVisualEnd(cmd, leaveSelection, ...)
	let mode = mode()
	if mode ==# 'V'
			let startLine = line('v')
			let endLine = line('.')
			call VSCodeNotifyRange(a:cmd, startLine, endLine, a:leaveSelection, a:000)
	elseif mode ==# 'v' || mode ==# "\<C-v>"
			let startPos = getpos('v')
			let endPos = getpos('.')
      let [startPos, endPos] = s:fixVisualEndPos(startPos, endPos)
			call VSCodeNotifyRangePos(a:cmd, startPos[1], endPos[1], startPos[2], endPos[2], a:leaveSelection, a:000)
	else
			call VSCodeNotify(a:cmd, a:000)
	endif
endfunction

function! VSCodeCallVisualEnd(cmd, leaveSelection, ...)
	let mode = mode()
	if mode ==# 'V'
			let startLine = line('v')
			let endLine = line('.')
			call VSCodeCallRange(a:cmd, startLine, endLine, a:leaveSelection, a:000)
	elseif mode ==# 'v' || mode ==# "\<C-v>"
			let startPos = getpos('v')
			let endPos = getpos('.')
      let [startPos, endPos] = s:fixVisualEndPos(startPos, endPos)
			call VSCodeCallRangePos(a:cmd, startPos[1], endPos[1], startPos[2], endPos[2], a:leaveSelection, a:000)
	else
			call VSCodeCall(a:cmd, a:000)
	endif
endfunction
