import clang.cindex
#clang.cindex.Config.set_library_path('')

unique_location = set()

def get_location(node):
    for t in node.get_tokens():
        return str(t.location)

def is_valid(node, func_name):
    for t in node.get_tokens():
        return t.spelling.startswith(func_name)

def printASTNode(node, level, parent, func_name, result_type):
    if parent is None: return
    global unique_location
    loc = get_location(node);
    if node.kind == clang.cindex.CursorKind.CALL_EXPR and node.type.spelling.startswith(result_type) and loc not in unique_location:
        unique_location.add(loc)
        if is_valid(node, func_name) or is_valid(parent, func_name): return
        print "Error Call_Expression"
        print "Type:(%s)" %(node.kind)
        print "Name:(%s)" %(node.spelling)
        for t in node.get_tokens():
            print t.location
            print "==========="
            break

def traverseAST(node, level, parent, func_name, result_type):
    if node is not None:
        level = level + 1
	#print "*" * level, node.kind
        printASTNode(node, level, parent, func_name, result_type)
        for childNode in node.get_children():
            traverseAST(childNode, level, node, func_name ,result_type)
        level = level - 1

def Check_CallExpr(file_name, func_name, result_type):
    index = clang.cindex.Index.create()
    translationUnit = index.parse(file_name)
    rootNode = translationUnit.cursor
    traverseAST(rootNode, 0, None, func_name, result_type)
