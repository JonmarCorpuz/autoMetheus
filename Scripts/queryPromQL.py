#!/usr/bin/python3

# ==== FUNCTIONS =================================================================================================
def metricMenu(): 
    print("""
    Available metrics:
    [1] System Metrics 
    [2] Application Metrics
    [3] Kubernetes Metrics
    """) 
    metric = int(input())
    return metric

def systemMetricMenu():
    print("""
    Available system metrics:
    [1] CPU Uptime
    [2] CPU Usage
    [3] Memory Usage
    """)
    systemMetric = int(input())

def applicationMetricMenu():
    print("""
    Available application metrics:
    [1]       
    """) 
    applicationMetric = int(input())

def kubernetesMetricMenu():
    print("""
    Available Kubernetes metrics:
    [1] 
    """) 
    kubernetesMetric = int(input())

while True:

    selectedMetric = metricMenu()

    # ==== SYSTEM METRICS ============================================================================================
    if selectedMetric == 1:
        print("tmp")

    # ==== APPLICATION METRICS =======================================================================================
    elif selectedMetric == 2:
        print("tmp")

    # ==== KUBERNETES METRICS ========================================================================================
    elif selectedMetric == 3:
        print("tmp")

    else:
        print("tmp")
