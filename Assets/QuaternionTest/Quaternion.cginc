#ifndef QUATERNION
#define QUATERNION

float4 unitQuaternion(float4 q)
{
	float norm = sqrt(q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w);
	q.x = q.x / norm;
	q.y = q.y / norm;
	q.z = q.z / norm;
	q.w = q.w / norm;
	return q;
}

float4 rotationAxisToQuaternion(float3 axis, float angle)
{
	float halfAngle = angle * 0.5;
	float sinHalfAngle = sin(halfAngle);
	return float4(
		axis.x * sinHalfAngle,
		axis.y * sinHalfAngle,
		axis.z * sinHalfAngle,
		cos(halfAngle)
	);
}

float4 positionToQuaternion(float3 pos)
{
	return float4(
		pos.x,
		pos.y,
		pos.z,
		0.0
	);
}

float4 inverseQuaternion(float4 q)
{
	float norm = sqrt(q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w);
	return float4(
		-q.x / norm,
		-q.y / norm,
		-q.z / norm,
		q.w / norm
	);
}

float4 quaternionConjugate(float4 q)
{
	return float4(-q.x, -q.y, -q.z, q.w);
}

float4 quaternionMultiply(float4 q1, float4 q2)
{
	return float4(
		(q1.w * q2.x) + (q1.x * q2.w) + (q1.y * q2.z) - (q1.z * q2.y),
		(q1.w * q2.y) - (q1.x * q2.z) + (q1.y * q2.w) + (q1.z * q2.x),
		(q1.w * q2.z) + (q1.x * q2.y) - (q1.y * q2.x) + (q1.z * q2.w),
		(q1.w * q2.w) - (q1.x * q2.x) - (q1.y * q2.y) - (q1.z * q2.z)
	);
}

float3 rotateVector(float3 v, float4 q)
{
	return v + 2.0 * cross(q.xyz, cross(q.xyz, v) + q.w * v);
}

// https://stackoverflow.com/questions/12435671/quaternion-lookat-function
float4 quaternionLookAt(float3 from, float3 to)
{
	float3 f = float3(0, 0, 1);
	float3 forwardVector = normalize(to - from);

	float3 rotAxis = cross(f, forwardVector);
	float d = dot(f, forwardVector);

	float4 q;
	q.x = rotAxis.x;
	q.y = rotAxis.y;
	q.z = rotAxis.z;
	q.w = d + 1.0;
	return normalize(q);
}

float4 quaternionLookAt(float3 from, float3 to, float3 front, float3 up)
{
	float3 toVector = normalize(to - from);

	float3 rotAxis = normalize(cross(front, toVector));
	rotAxis = (rotAxis.x * rotAxis.x + rotAxis.y * rotAxis.y + rotAxis.z * rotAxis.z) == 0.0 ? up : rotAxis;

	float d = dot(front, toVector);
	float ang = acos(d);
	
	return rotationAxisToQuaternion(rotAxis, ang);
}

float4 quaternionSlerp(float4 q0, float4 q1, float t)
{
	q0 = normalize(q0);
	q1 = normalize(q1);

	float dot_q0q1 = dot(q0, q1);

	bool dotIsNegative = dot_q0q1 < 0.0;
	q1 = dotIsNegative ? -q1 : q1;
	dot_q0q1 = dotIsNegative ? -dot_q0q1 : dot_q0q1;

	const float DOT_THREDHOLD = 0.9995;
	bool valuesAreTooClose = dot_q0q1 > 0.9995;
	if (valuesAreTooClose)
	{
		float4 result = q0 + t * (q1 - q0);
		result = normalize(result);
		return result;
	}

	float theta0 = acos(dot_q0q1);
	float theta = theta0 * t;
	float sinTheta = sin(theta);
	float sinTheta0 = sin(theta0);
	float s0 = cos(theta) - dot_q0q1 * sinTheta / sinTheta0;
	float s1 = sinTheta / sinTheta0;

	return (s0 * q0) + (s1 * q1);
}
#endif