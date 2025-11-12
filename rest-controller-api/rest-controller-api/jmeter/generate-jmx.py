#!/usr/bin/env python3
"""
JMeter Test Plan Generator for REST API Performance Testing
Generates 4 .jmx files for different test scenarios
"""

import xml.etree.ElementTree as ET
from xml.dom import minidom

def create_jmeter_header():
    """Create JMeter test plan header"""
    root = ET.Element('jmeterTestPlan', {
        'version': '1.2',
        'properties': '5.0',
        'jmeter': '5.6'
    })
    return root

def add_test_plan(root, name):
    """Add test plan element"""
    hashTree = ET.SubElement(root, 'hashTree')
    testPlan = ET.SubElement(hashTree, 'TestPlan', {
        'guiclass': 'TestPlanGui',
        'testclass': 'TestPlan',
        'testname': name,
        'enabled': 'true'
    })
    
    # String properties
    ET.SubElement(testPlan, 'stringProp', {'name': 'TestPlan.comments'})
    ET.SubElement(testPlan, 'boolProp', {'name': 'TestPlan.functional_mode'}).text = 'false'
    ET.SubElement(testPlan, 'boolProp', {'name': 'TestPlan.serialize_threadgroups'}).text = 'false'
    ET.SubElement(testPlan, 'elementProp', {
        'name': 'TestPlan.user_defined_variables',
        'elementType': 'Arguments',
        'guiclass': 'ArgumentsPanel',
        'testclass': 'Arguments',
        'testname': 'User Defined Variables',
        'enabled': 'true'
    })
    
    return ET.SubElement(hashTree, 'hashTree')

def add_thread_group(parent, name, num_threads, ramp_time, duration):
    """Add thread group"""
    threadGroup = ET.SubElement(parent, 'ThreadGroup', {
        'guiclass': 'ThreadGroupGui',
        'testclass': 'ThreadGroup',
        'testname': name,
        'enabled': 'true'
    })
    
    ET.SubElement(threadGroup, 'stringProp', {'name': 'ThreadGroup.on_sample_error'}).text = 'continue'
    ET.SubElement(threadGroup, 'elementProp', {
        'name': 'ThreadGroup.main_controller',
        'elementType': 'LoopController',
        'guiclass': 'LoopControlPanel',
        'testclass': 'LoopController',
        'testname': 'Loop Controller',
        'enabled': 'true'
    })
    
    loopController = threadGroup.find('.//elementProp[@name="ThreadGroup.main_controller"]')
    ET.SubElement(loopController, 'boolProp', {'name': 'LoopController.continue_forever'}).text = 'false'
    ET.SubElement(loopController, 'intProp', {'name': 'LoopController.loops'}).text = '-1'
    
    ET.SubElement(threadGroup, 'stringProp', {'name': 'ThreadGroup.num_threads'}).text = str(num_threads)
    ET.SubElement(threadGroup, 'stringProp', {'name': 'ThreadGroup.ramp_time'}).text = str(ramp_time)
    ET.SubElement(threadGroup, 'boolProp', {'name': 'ThreadGroup.scheduler'}).text = 'true'
    ET.SubElement(threadGroup, 'stringProp', {'name': 'ThreadGroup.duration'}).text = str(duration)
    ET.SubElement(threadGroup, 'stringProp', {'name': 'ThreadGroup.delay'}).text = '0'
    
    return ET.SubElement(parent, 'hashTree')

def add_http_defaults(parent, host='${__P(host,localhost)}', port='${__P(port,8081)}'):
    """Add HTTP Request Defaults"""
    defaults = ET.SubElement(parent, 'ConfigTestElement', {
        'guiclass': 'HttpDefaultsGui',
        'testclass': 'ConfigTestElement',
        'testname': 'HTTP Request Defaults',
        'enabled': 'true'
    })
    
    ET.SubElement(defaults, 'elementProp', {
        'name': 'HTTPsampler.Arguments',
        'elementType': 'Arguments',
        'guiclass': 'HTTPArgumentsPanel',
        'testclass': 'Arguments',
        'testname': 'User Defined Variables',
        'enabled': 'true'
    })
    
    ET.SubElement(defaults, 'stringProp', {'name': 'HTTPSampler.domain'}).text = host
    ET.SubElement(defaults, 'stringProp', {'name': 'HTTPSampler.port'}).text = port
    ET.SubElement(defaults, 'stringProp', {'name': 'HTTPSampler.protocol'}).text = 'http'
    ET.SubElement(defaults, 'stringProp', {'name': 'HTTPSampler.contentEncoding'})
    ET.SubElement(defaults, 'stringProp', {'name': 'HTTPSampler.path'})
    
    ET.SubElement(parent, 'hashTree')

def add_http_request(parent, name, method, path, body=None):
    """Add HTTP Request sampler"""
    sampler = ET.SubElement(parent, 'HTTPSamplerProxy', {
        'guiclass': 'HttpTestSampleGui',
        'testclass': 'HTTPSamplerProxy',
        'testname': name,
        'enabled': 'true'
    })
    
    ET.SubElement(sampler, 'boolProp', {'name': 'HTTPSampler.postBodyRaw'}).text = 'true' if body else 'false'
    ET.SubElement(sampler, 'elementProp', {
        'name': 'HTTPsampler.Arguments',
        'elementType': 'Arguments',
        'guiclass': 'HTTPArgumentsPanel',
        'testclass': 'Arguments',
        'testname': 'User Defined Variables',
        'enabled': 'true'
    })
    
    if body:
        collectionProp = ET.SubElement(sampler.find('.//elementProp[@name="HTTPsampler.Arguments"]'), 'collectionProp', {'name': 'Arguments.arguments'})
        elementProp = ET.SubElement(collectionProp, 'elementProp', {'name': '', 'elementType': 'HTTPArgument'})
        ET.SubElement(elementProp, 'boolProp', {'name': 'HTTPArgument.always_encode'}).text = 'false'
        ET.SubElement(elementProp, 'stringProp', {'name': 'Argument.value'}).text = body
        ET.SubElement(elementProp, 'stringProp', {'name': 'Argument.metadata'}).text = '='
    
    ET.SubElement(sampler, 'stringProp', {'name': 'HTTPSampler.domain'})
    ET.SubElement(sampler, 'stringProp', {'name': 'HTTPSampler.port'})
    ET.SubElement(sampler, 'stringProp', {'name': 'HTTPSampler.protocol'})
    ET.SubElement(sampler, 'stringProp', {'name': 'HTTPSampler.contentEncoding'})
    ET.SubElement(sampler, 'stringProp', {'name': 'HTTPSampler.path'}).text = path
    ET.SubElement(sampler, 'stringProp', {'name': 'HTTPSampler.method'}).text = method
    ET.SubElement(sampler, 'boolProp', {'name': 'HTTPSampler.follow_redirects'}).text = 'true'
    ET.SubElement(sampler, 'boolProp', {'name': 'HTTPSampler.auto_redirects'}).text = 'false'
    ET.SubElement(sampler, 'boolProp', {'name': 'HTTPSampler.use_keepalive'}).text = 'true'
    
    if body:
        header = ET.SubElement(parent, 'HeaderManager', {
            'guiclass': 'HeaderPanel',
            'testclass': 'HeaderManager',
            'testname': 'HTTP Header Manager',
            'enabled': 'true'
        })
        collectionProp = ET.SubElement(header, 'collectionProp', {'name': 'HeaderManager.headers'})
        elementProp = ET.SubElement(collectionProp, 'elementProp', {'name': '', 'elementType': 'Header'})
        ET.SubElement(elementProp, 'stringProp', {'name': 'Header.name'}).text = 'Content-Type'
        ET.SubElement(elementProp, 'stringProp', {'name': 'Header.value'}).text = 'application/json'
        ET.SubElement(parent, 'hashTree')
    
    ET.SubElement(parent, 'hashTree')

def prettify(elem):
    """Return a pretty-printed XML string"""
    rough_string = ET.tostring(elem, 'utf-8')
    reparsed = minidom.parseString(rough_string)
    return reparsed.toprettyxml(indent="  ")

# Generate Scenario 1: READ Heavy
print("Generating scenario1-read-heavy.jmx...")
root1 = create_jmeter_header()
testPlanHash = add_test_plan(root1, "Scenario 1: READ Heavy")
threadGroupHash = add_thread_group(testPlanHash, "READ Heavy Users", 200, 60, 600)
add_http_defaults(threadGroupHash)

# Add requests with throughput controller for distribution
add_http_request(threadGroupHash, "GET Items Paginated", "GET", "/items?page=0&size=50")
add_http_request(threadGroupHash, "GET Items by Category", "GET", "/items?categoryId=${__Random(1,2000)}&page=0&size=50")
add_http_request(threadGroupHash, "GET Category Items", "GET", "/categories/${__Random(1,2000)}/items?page=0&size=50")
add_http_request(threadGroupHash, "GET Categories", "GET", "/categories?page=0&size=50")

with open('scenario1-read-heavy.jmx', 'w', encoding='utf-8') as f:
    f.write(prettify(root1))

# Generate Scenario 2: JOIN Filter
print("Generating scenario2-join-filter.jmx...")
root2 = create_jmeter_header()
testPlanHash = add_test_plan(root2, "Scenario 2: JOIN Filter")
threadGroupHash = add_thread_group(testPlanHash, "JOIN Filter Users", 120, 60, 600)
add_http_defaults(threadGroupHash)

add_http_request(threadGroupHash, "GET Items by Category", "GET", "/items?categoryId=${__Random(1,2000)}&page=0&size=50")
add_http_request(threadGroupHash, "GET Item by ID", "GET", "/items/${__Random(1,100000)}")

with open('scenario2-join-filter.jmx', 'w', encoding='utf-8') as f:
    f.write(prettify(root2))

# Generate Scenario 3: Mixed Operations
print("Generating scenario3-mixed.jmx...")
root3 = create_jmeter_header()
testPlanHash = add_test_plan(root3, "Scenario 3: Mixed Operations")
threadGroupHash = add_thread_group(testPlanHash, "Mixed Users", 100, 60, 600)
add_http_defaults(threadGroupHash)

add_http_request(threadGroupHash, "GET Items", "GET", "/items?page=0&size=50")
add_http_request(threadGroupHash, "GET Item by ID", "GET", "/items/${__Random(1,100000)}")

item_body_1kb = '{"name":"Test Item ${__Random(1,999999)}","description":"' + ('A' * 900) + '","price":${__Random(1,1000)}.99,"quantity":${__Random(1,100)},"categoryId":${__Random(1,2000)}}'
add_http_request(threadGroupHash, "POST Item", "POST", "/items", item_body_1kb)

update_body_1kb = '{"name":"Updated Item ${__Random(1,999999)}","description":"' + ('B' * 900) + '","price":${__Random(1,1000)}.99,"quantity":${__Random(1,100)},"categoryId":${__Random(1,2000)}}'
add_http_request(threadGroupHash, "PUT Item", "PUT", "/items/${__Random(1,100000)}", update_body_1kb)

add_http_request(threadGroupHash, "DELETE Item", "DELETE", "/items/${__Random(90000,100000)}")

with open('scenario3-mixed.jmx', 'w', encoding='utf-8') as f:
    f.write(prettify(root3))

# Generate Scenario 4: Heavy Body
print("Generating scenario4-heavy-body.jmx...")
root4 = create_jmeter_header()
testPlanHash = add_test_plan(root4, "Scenario 4: Heavy Body")
threadGroupHash = add_thread_group(testPlanHash, "Heavy Body Users", 60, 60, 600)
add_http_defaults(threadGroupHash)

item_body_5kb = '{"name":"Heavy Item ${__Random(1,999999)}","description":"' + ('X' * 4800) + '","price":${__Random(1,1000)}.99,"quantity":${__Random(1,100)},"categoryId":${__Random(1,2000)}}'
add_http_request(threadGroupHash, "POST Heavy Item", "POST", "/items", item_body_5kb)

update_body_5kb = '{"name":"Heavy Updated ${__Random(1,999999)}","description":"' + ('Y' * 4800) + '","price":${__Random(1,1000)}.99,"quantity":${__Random(1,100)},"categoryId":${__Random(1,2000)}}'
add_http_request(threadGroupHash, "PUT Heavy Item", "PUT", "/items/${__Random(1,100000)}", update_body_5kb)

add_http_request(threadGroupHash, "GET Items", "GET", "/items?page=0&size=50")

with open('scenario4-heavy-body.jmx', 'w', encoding='utf-8') as f:
    f.write(prettify(root4))

print("✓ All JMeter test plans generated successfully!")
print("  - scenario1-read-heavy.jmx")
print("  - scenario2-join-filter.jmx")
print("  - scenario3-mixed.jmx")
print("  - scenario4-heavy-body.jmx")
